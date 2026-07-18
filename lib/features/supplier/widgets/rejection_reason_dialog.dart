import 'package:flutter/material.dart';

class RejectionReasonDialog extends StatefulWidget {
  const RejectionReasonDialog({super.key});

  // Returns the trimmed reason when the user confirms, or null when cancelled.
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RejectionReasonDialog(),
    );
  }

  @override
  State<RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<RejectionReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  static const int _maxLength = 255;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F1B30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Từ chối đơn mua',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLines: 4,
          minLines: 3,
          maxLength: _maxLength,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Lý do từ chối',
            labelStyle: const TextStyle(color: Color(0xFFB7CDE5)),
            hintText: 'Nhập lý do từ chối đơn mua...',
            hintStyle: const TextStyle(color: Color(0xFF7E92AD), fontSize: 13),
            filled: true,
            fillColor: Colors.white.withAlpha(10),
            counterStyle: const TextStyle(color: Color(0xFF7E92AD), fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withAlpha(25)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withAlpha(25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF7070), width: 1.5),
            ),
            errorStyle: const TextStyle(color: Color(0xFFFF7070), fontSize: 12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập lý do từ chối.';
            }
            if (value.trim().length > _maxLength) {
              return 'Lý do không được vượt quá $_maxLength ký tự.';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Hủy',
            style: TextStyle(color: Color(0xFFB7CDE5), fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7070),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'Xác nhận từ chối',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
