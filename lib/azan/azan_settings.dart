import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/notification_model.dart';

class AzanSettings extends StatefulWidget {
  const AzanSettings({super.key});

  @override
  State<AzanSettings> createState() => _AzanSettingsState();
}

class _AzanSettingsState extends State<AzanSettings> {
  @override
  Widget build(BuildContext context) {
    NotificationSoundType soundType = NotificationSoundType.Sound;
    return  Column(
      children: [
        ListTile(
          title: Text('Vibrate'),
          leading: Radio<NotificationSoundType>(
            value: NotificationSoundType.Vibrate,
            groupValue: soundType,
            onChanged: (NotificationSoundType? value) {
              setState(() {
                soundType = value!;
                saveSoundPreference(value);
              });
            },
          ),
        ),
        ListTile(
          title: Text('Sound'),
          leading: Radio<NotificationSoundType>(
            value: NotificationSoundType.Sound,
            groupValue: soundType,
            onChanged: (NotificationSoundType? value) {
              setState(() {
                soundType = value!;
                saveSoundPreference(value);
              });
            },
          ),
        ),
        ListTile(
          title: Text('Mute'),
          leading: Radio<NotificationSoundType>(
            value: NotificationSoundType.Mute,
            groupValue: soundType,
            onChanged: (NotificationSoundType? value) {
              setState(() {
                soundType = value!;
                saveSoundPreference(value);
              });
            },
          ),
        ),
      ],
    );
  }
}
