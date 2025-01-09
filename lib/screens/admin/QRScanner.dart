import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isAdmin = false; // Kiểm tra nếu người dùng là admin

  @override
  void initState() {
    super.initState();
    _checkAdminStatus(); // Kiểm tra quyền admin khi bắt đầu
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quét mã QR')),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (BarcodeCapture barcodeCapture) async {
          final ticketId = barcodeCapture.barcodes.first.rawValue; // Lấy rawValue từ Barcode

          if (ticketId != null) {
            // Kiểm tra trong Firestore xem vé có tồn tại không
            final ticketSnapshot = await FirebaseFirestore.instance
                .collection('invoices')
                .get();

            bool ticketFound = false; // Biến để kiểm tra nếu vé đã tìm thấy
            String ticketTypeId = '';
            String ticketTypeName = ''; // Biến để lưu tên loại vé

            // Duyệt qua từng hóa đơn
            for (var doc in ticketSnapshot.docs) {
              var invoiceData = doc.data() as Map<String, dynamic>;
              var ticketDetails = invoiceData['ticket_details'] as List;

              // Duyệt qua từng vé trong ticket_details để kiểm tra 'id'
              for (var ticket in ticketDetails) {
                if (ticket['id'] == ticketId) {
                  ticketFound = true; // Vé đã được tìm thấy
                  ticketTypeId = ticket['ticket_type_id'];

                  // Lấy tên loại vé từ collection 'ticket_types' theo ticketTypeId
                  var ticketTypeSnapshot = await FirebaseFirestore.instance
                      .collection('ticket_types')
                      .doc(ticketTypeId)
                      .get();

                  if (ticketTypeSnapshot.exists) {
                    ticketTypeName = ticketTypeSnapshot.data()?['name'] ?? 'Không có tên loại vé';
                  }

                  // Nếu vé đã được sử dụng
                  if (ticket['is_used']) {
                    _showDialog(Icons.error, 'Vé đã được sử dụng.', ticketTypeName);
                    return; // Dừng lại sau khi tìm thấy vé đã sử dụng
                  } else {
                    // Nếu người dùng là admin, cho phép thay đổi trạng thái vé
                    if (isAdmin) {
                      ticket['is_used'] = true;
                      await FirebaseFirestore.instance
                          .collection('invoices')
                          .doc(doc.id)
                          .update({'ticket_details': ticketDetails});

                      // Hiển thị thông báo thành công cho admin
                      _showDialog(Icons.check_circle, 'Vé đã được sử dụng thành công.', ticketTypeName);
                      return; // Dừng lại sau khi cập nhật
                    }
                  }
                }
              }
            }
            // Nếu không tìm thấy vé
            if (!ticketFound) {
              _showDialog(Icons.error, 'Vé không hợp lệ.', ticketTypeName);
            }
          }
        },
      ),
    );
  }

  // Hiển thị thông báo trong hộp thoại
  void _showDialog(IconData icon, String message, String ticketTypeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Icon(icon, color: icon == Icons.error ? Colors.red : Colors.green, size: 80),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (ticketTypeName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Tên loại vé: $ticketTypeName', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Kiểm tra trạng thái admin của người dùng
  void _checkAdminStatus() async {
    // Lấy thông tin người dùng hiện tại từ Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Kiểm tra nếu người dùng có quyền admin
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;
        if (userData['role'] == 'admin') {
          setState(() {
            isAdmin = true;
          });
        }
      }
    }
  }
}
