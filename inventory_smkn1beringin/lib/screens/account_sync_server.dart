import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 4545);
  final file = File('accounts.json');

  print('================================');
  print('ACCOUNT SYNC SERVER BERHASIL');
  print('Server berjalan di port 4545');
  print('================================');

  await for (final request in server) {
    request.response.headers.set(
      HttpHeaders.accessControlAllowOriginHeader,
      '*',
    );
    request.response.headers.set(
      HttpHeaders.accessControlAllowMethodsHeader,
      'GET, POST, PUT, OPTIONS',
    );
    request.response.headers.set(
      HttpHeaders.accessControlAllowHeadersHeader,
      'Content-Type',
    );
    request.response.headers.contentType = ContentType.json;

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      continue;
    }

    try {
      if (request.uri.path == '/health' && request.method == 'GET') {
        request.response.write(
          jsonEncode({'status': 'success', 'message': 'Server aktif'}),
        );
      } else if (request.uri.path == '/accounts' && request.method == 'GET') {
        if (await file.exists()) {
          request.response.write(await file.readAsString());
        } else {
          request.response.write('[]');
        }
      } else if (request.uri.path == '/accounts' && request.method == 'POST') {
        final body = await utf8.decoder.bind(request).join();
        final account = jsonDecode(body);

        if (account is! Map ||
            account['username'] == null ||
            account['password'] == null ||
            account['role'] == null) {
          throw const FormatException('Data akun tidak lengkap');
        }

        List accounts = [];

        if (await file.exists()) {
          accounts = jsonDecode(await file.readAsString());
        }

        final exists = accounts.any(
          (item) =>
              item['username'].toString().toLowerCase() ==
              account['username'].toString().toLowerCase(),
        );

        if (exists) {
          request.response.statusCode = HttpStatus.conflict;
          request.response.write(
            jsonEncode({
              'status': 'error',
              'message': 'Username sudah digunakan',
            }),
          );
        } else {
          accounts.add({
            'username': account['username'],
            'password': account['password'],
            'role': account['role'],
            'approvalStatus': 'Menunggu',
          });

          await file.writeAsString(jsonEncode(accounts));

          request.response.write(
            jsonEncode({
              'status': 'success',
              'message': 'Akun berhasil disimpan',
            }),
          );
        }
      } else if (request.uri.path == '/accounts' && request.method == 'PUT') {
        final body = await utf8.decoder.bind(request).join();
        final data = jsonDecode(body);

        if (data is! Map ||
            data['username'] == null ||
            ![
              'Menunggu',
              'Disetujui',
              'Ditolak',
            ].contains(data['approvalStatus'])) {
          throw const FormatException('Data persetujuan tidak valid');
        }

        List accounts = [];

        if (await file.exists()) {
          accounts = jsonDecode(await file.readAsString());
        }

        final index = accounts.indexWhere(
          (item) =>
              item['username'].toString().toLowerCase() ==
              data['username'].toString().toLowerCase(),
        );

        if (index == -1) {
          request.response.statusCode = HttpStatus.notFound;
          request.response.write(
            jsonEncode({'status': 'error', 'message': 'Akun tidak ditemukan'}),
          );
        } else {
          accounts[index]['approvalStatus'] = data['approvalStatus'];

          await file.writeAsString(
            const JsonEncoder.withIndent('  ').convert(accounts),
            flush: true,
          );

          print(
            'Status akun ${accounts[index]['username']} '
            'diubah menjadi ${data['approvalStatus']}',
          );

          request.response.write(
            jsonEncode({
              'status': 'success',
              'message': 'Status akun berhasil diperbarui',
            }),
          );
        }
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write(
          jsonEncode({
            'status': 'error',
            'message': 'Endpoint tidak ditemukan',
          }),
        );
      }
    } catch (e) {
      print('ERROR SERVER: $e');
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write(
        jsonEncode({'status': 'error', 'message': e.toString()}),
      );
    }

    await request.response.close();
  }
}
