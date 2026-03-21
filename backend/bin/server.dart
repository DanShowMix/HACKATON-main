import 'dart:io';
import '../lib/server/api_server.dart';

void main(List<String> args) async {
  // Parse command line arguments
  String host = '0.0.0.0';
  int port = 8080;

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--host' && i + 1 < args.length) {
      host = args[i + 1];
    } else if (args[i] == '--port' && i + 1 < args.length) {
      port = int.parse(args[i + 1]);
    } else if (args[i] == '--help') {
      print('Usage: dart bin/server.dart [options]');
      print('Options:');
      print('  --host <host>  Host to bind to (default: 0.0.0.0)');
      print('  --port <port>  Port to bind to (default: 8080)');
      print('  --help         Show this help message');
      exit(0);
    }
  }

  print('🚀 Starting Dealer Partner Backend Server...');
  print('📍 Host: $host');
  print('🔌 Port: $port');
  print('');

  try {
    final server = ApiServer(host: host, port: port);
    await server.start();

    // Handle shutdown
    ProcessSignal.sigint.watch().listen((_) async {
      print('\n👋 Shutting down...');
      await server.stop();
      exit(0);
    });

    // Keep the server running
    await ProcessSignal.sigint.watch().first;
  } catch (e) {
    print('❌ Error starting server: $e');
    exit(1);
  }
}
