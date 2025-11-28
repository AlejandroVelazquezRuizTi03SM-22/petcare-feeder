import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart' show rootBundle;

class PrivacyCheckbox extends StatefulWidget {
  final bool accepted;
  final ValueChanged<bool> onChanged;

  const PrivacyCheckbox({
    super.key,
    required this.accepted,
    required this.onChanged,
  });

  @override
  State<PrivacyCheckbox> createState() => _PrivacyCheckboxState();
}

class _PrivacyCheckboxState extends State<PrivacyCheckbox> {
  // controlador para el Scrollbar
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showMarkdownDialog(
    BuildContext ctx,
    String path,
    String title,
  ) async {
    try {
      final data = await rootBundle.loadString(path); // carga del asset
      print(data); // opcional: ver en consola el contenido cargado

      if (!mounted) return;

      showDialog(
        context: ctx,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(title),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(dialogContext).size.height * 0.7,
                maxWidth: MediaQuery.of(dialogContext).size.width * 0.9,
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: MarkdownBody(data: data, selectable: true),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('No se pudo cargar el documento: $path')),
      );
      print(e); // opcional: ver el error en consola
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CheckboxListTile hace todo el renglón clickable
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: widget.accepted,
          onChanged: (v) => widget.onChanged(v ?? false),
          title: InkWell(
            onTap: () => _showMarkdownDialog(
              context,
              'docs/privacy/AVISO_PRIVACIDAD_v1.0.md',
              'Aviso de Privacidad',
            ),
            child: const Text(
              'He leído y acepto el Aviso de Privacidad',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => _showMarkdownDialog(
                context,
                'docs/privacy/PROTECCION_DATOS_v1.0.md',
                'Protección de Datos',
              ),
              child: const Text('Ver: Protección de Datos'),
            ),
            TextButton(
              onPressed: () => _showMarkdownDialog(
                context,
                'docs/privacy/DOCUMENTO_ARCO_v1.0.md',
                'Documento ARCO',
              ),
              child: const Text('Ver: Documento ARCO'),
            ),
          ],
        ),
      ],
    );
  }
}
