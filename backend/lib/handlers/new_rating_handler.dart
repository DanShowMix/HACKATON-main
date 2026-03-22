import 'package:shelf/shelf.dart';
import '../repositories/repositories.dart';
import '../models/models.dart';
import '../utils/response_helpers.dart';
import 'auth_handler.dart';

/// New rating handler with updated formula
class NewRatingHandler {
  static final MonthlyRatingRepository _ratingRepo = MonthlyRatingRepository();
  static final MonthlyPlanRepository _planRepo = MonthlyPlanRepository();
  static final LoanApplicationRepository _appRepo = LoanApplicationRepository();
  static final EmployeeBenefitRepository _benefitRepo = EmployeeBenefitRepository();
  static final MonthlyBenefitRepository _monthlyBenefitRepo = MonthlyBenefitRepository();

  /// Get current month rating for employee
  static Future<Response> getCurrentRating(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final currentMonth = _getCurrentMonth();
      
      // Get or calculate rating for current month
      var rating = await _ratingRepo.getByEmployeeIdAndMonth(userId, currentMonth);
      
      if (rating == null) {
        // Calculate new rating
        rating = await _calculateRating(userId, currentMonth);
      }

      return ok(rating.toJson());
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Calculate rating using new formula
  static Future<MonthlyRating> _calculateRating(String employeeId, String month) async {
    // Get plans
    final plan = await _planRepo.getByEmployeeIdAndMonth(employeeId, month);
    final volumePlan = plan?.volumePlan ?? 10.0;
    final dealsPlan = plan?.dealsPlan ?? 10;
    final bankShareTarget = plan?.bankShareTarget ?? 50.0;

    // Get actual volume from deals
    final deals = await DealRepository().getByEmployeeId(employeeId);
    final volumeFact = deals.fold<double>(0, (sum, d) => sum + (d.amount / 1000000)); // in millions
    final dealsFact = deals.length;

    // Get bank share from employee
    final employee = await EmployeeRepository().getById(employeeId);
    final bankShareFact = employee?.bankShare ?? 0;

    // Get conversion rate from applications
    final apps = await _appRepo.getByEmployeeId(employeeId);
    final approvedApps = apps.where((a) => a.status == 'approved').length;
    final decidedApps = apps.where((a) => a.status == 'approved' || a.status == 'rejected').length;
    final conversionRate = decidedApps > 0 ? (approvedApps / decidedApps * 100) : 0;

    // Calculate indices with caps
    final volumeIndex = _capAt120((volumeFact / volumePlan) * 100);
    final dealsIndex = (dealsFact / dealsPlan) * 100;
    final bankShareIndex = (bankShareFact / bankShareTarget) * 100;
    final conversionIndex = conversionRate;

    // Calculate total score using formula
    final totalScore = 0.35 * volumeIndex + 
                       0.25 * dealsIndex + 
                       0.25 * bankShareIndex + 
                       0.15 * conversionIndex;

    // Determine level
    final level = _getLevel(totalScore);

    // Create rating
    final rating = MonthlyRating(
      id: 'rating-${month}-$employeeId',
      employeeId: employeeId,
      month: month,
      volumeFact: volumeFact,
      volumePlan: volumePlan,
      volumeIndex: volumeIndex,
      dealsFact: dealsFact,
      dealsPlan: dealsPlan,
      dealsIndex: dealsIndex,
      bankShareFact: bankShareFact.toDouble(),
      bankShareTarget: bankShareTarget,
      bankShareIndex: bankShareIndex,
      conversionRate: conversionRate.toDouble(),
      conversionIndex: conversionIndex.toDouble(),
      totalScore: totalScore,
      level: level,
    );

    await _ratingRepo.create(rating);

    // Update employee level if needed
    if (employee != null && employee.level != level) {
      await EmployeeRepository().updateLevel(employeeId, level);
    }

    return rating;
  }

  /// Get financial effect with new calculation
  static Future<Response> getFinancialEffect(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final currentMonth = _getCurrentMonth();
      final year = DateTime.now().year.toString();

      // Get or calculate monthly benefits
      var monthlyBenefit = await _monthlyBenefitRepo.getByEmployeeIdAndMonth(userId, currentMonth);
      
      if (monthlyBenefit == null) {
        monthlyBenefit = await _calculateMonthlyBenefits(userId, currentMonth, year);
      }

      // Get year-to-date total
      final yearTotal = await _monthlyBenefitRepo.getYearTotal(userId, year);

      return ok({
        ...monthlyBenefit.toJson(),
        'yearTotalBenefit': yearTotal,
        'period': year,
      });
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Calculate monthly benefits based on privileges
  static Future<MonthlyBenefit> _calculateMonthlyBenefits(
    String employeeId, 
    String month, 
    String year,
  ) async {
    final benefits = await _benefitRepo.getByEmployeeId(employeeId);
    
    // Calculate bonus income from subscription
    // Assume average monthly spending of 100,000 RUB
    final avgMonthlySpending = 100000;
    final bonusPercent = benefits?.bonusPercent ?? 0;
    final bonusIncome = (avgMonthlySpending * bonusPercent).round();

    // Calculate mortgage savings
    // 1% discount on remaining mortgage, divided by 12 months
    final mortgageRemaining = benefits?.mortgageRemaining ?? 0;
    final mortgageDiscount = benefits?.mortgageDiscountPercent ?? 0;
    final mortgageSavings = (mortgageRemaining * mortgageDiscount / 12).round();

    // DMS compensation (annual / 12)
    final dmsCompensation = (benefits?.dmsCompensation ?? 0) ~/ 12;

    final totalMonthly = bonusIncome + mortgageSavings + dmsCompensation;

    final benefit = MonthlyBenefit(
      id: 'benefit-$month-$employeeId',
      employeeId: employeeId,
      month: month,
      bonusIncome: bonusIncome,
      mortgageSavings: mortgageSavings,
      dmsCompensation: dmsCompensation,
      totalMonthlyBenefit: totalMonthly,
      yearTotalBenefit: totalMonthly, // Will be updated
    );

    await _monthlyBenefitRepo.create(benefit);
    return benefit;
  }

  /// Get level based on score
  static String _getLevel(double score) {
    if (score >= 90) return 'Black';
    if (score >= 70) return 'Gold';
    return 'Silver';
  }

  /// Cap index at 120
  static double _capAt120(double value) {
    return value > 120 ? 120 : value;
  }

  /// Get current month in YYYY-MM format
  static String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }
}
