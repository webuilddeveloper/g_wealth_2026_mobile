import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// หน้าช่วยถามโรคพืช — เลือกรูปจากคลังแล้วส่งคำถามกลับไปแชท
class PlantDiagnosisPage extends StatefulWidget {
  const PlantDiagnosisPage({super.key});

  @override
  State<PlantDiagnosisPage> createState() => _PlantDiagnosisPageState();
}

class _PlantDiagnosisPageState extends State<PlantDiagnosisPage> {
  final _noteController = TextEditingController();
  final _picker = ImagePicker();
  String? _pickedName;
  var _busy = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      setState(() => _pickedName = file?.name);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    final note = _noteController.text.trim();
    final buffer = StringBuffer('ช่วยวินิจฉัยโรคพืชให้หน่อย');
    if (_pickedName != null && _pickedName!.isNotEmpty) {
      buffer.write(' (แนบรูป: $_pickedName)');
    }
    if (note.isNotEmpty) {
      buffer.write(' อาการ: $note');
    }
    Navigator.of(context).pop(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF678E19);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ถ่ายรูปถามโรคพืช'),
        backgroundColor: brand,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'เลือกรูปจากคลังรูปภาพ แล้วอธิบายอาการสั้นๆ ได้ (ไม่บังคับ)',
            style: TextStyle(height: 1.45),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _busy ? null : _pickImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(_pickedName == null ? 'เลือกจากคลังรูป' : 'เปลี่ยนรูป'),
          ),
          if (_pickedName != null) ...[
            const SizedBox(height: 8),
            Text('เลือกแล้ว: $_pickedName', style: const TextStyle(color: brand)),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'อาการเพิ่มเติม',
              hintText: 'เช่น ใบเหลือง มีจุดน้ำตาล...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _submit,
            style: FilledButton.styleFrom(backgroundColor: brand),
            child: const Text('ส่งคำถามไปแชท'),
          ),
        ],
      ),
    );
  }
}
