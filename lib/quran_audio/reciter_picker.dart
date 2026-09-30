import 'package:flutter/material.dart';

import '../enum/reciter_list_enum.dart';
import '../quran_ayah/reader_theme.dart';
import 'quran_audio_service.dart';

/// A searchable reciter list.
///
/// The old screen put the reciter in a `DropdownButton` built inside a
/// `ListView.builder` with **no `itemCount`** — an unbounded list that keeps
/// creating identical dropdowns as far as it is scrolled. Only one was ever
/// visible, inside a 60-pixel box, so the bug was invisible and simply
/// wasted work forever.
Future<String?> showReciterPicker(BuildContext context, String current) {
  final t = ReaderTheme.read(context);
  final controller = TextEditingController();
  var query = '';

  List<ReciterName> visible() => ReciterName.values.where((r) {
    if (query.isEmpty) return true;
    return r.label.toLowerCase().contains(query) ||
        r.text.toLowerCase().contains(query);
  }).toList();

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: t.paper,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        final shown = visible();
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          builder: (_, scroll) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Search reciters',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (q) =>
                      setSheet(() => query = q.trim().toLowerCase()),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: shown.length,
                  itemBuilder: (_, i) {
                    final r = shown[i];
                    final isCurrent = r.text == current;
                    return ListTile(
                      leading: Icon(
                        Icons.record_voice_over,
                        size: 20,
                        color: isCurrent ? ReaderTheme.green : t.inkSoft,
                      ),
                      title: Text(reciterLabels[r.text] ?? r.label.trim()),
                      subtitle: Text(
                        r.text,
                        style: TextStyle(fontSize: 11, color: t.inkSoft),
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.check, color: ReaderTheme.green)
                          : null,
                      onTap: () => Navigator.pop(ctx, r.text),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
