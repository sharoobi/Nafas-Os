# Guarded Audio Retraining Loop

## الهدف

إغلاق حلقة الحراسة الصوتية بالكامل:

1. جمع جلسات صوتية حقيقية من استخدام المستخدم.
2. حفظ الميزات الهندسية المستخرجة محليًا داخل SQLite.
3. وسم الجلسة من داخل `Rescue`.
4. تصدير dataset موسوم إلى ملف CSV.
5. إعادة بناء نموذج `TFLite` باستخدام البيانات الحقيقية بدل الاعتماد الكامل على البيانات الاصطناعية.

## ما الذي يُحفظ الآن

جدول `guarded_audio_training_sample` يحتوي:

- `captured_at`
- `started_at`
- `ended_at`
- `session_duration_seconds`
- `average_amplitude`
- `peak_amplitude`
- `lighter_like_spikes`
- `cough_like_bursts`
- `steady_breath_cycles`
- `restlessness_bursts`
- `audio_risk_score`
- `sample_count`
- `predicted_label`
- `predicted_confidence`
- `prediction_source`
- `recommended_action`
- `confirmed_label`

## كيف تُجمع الجلسات

عند انتهاء جلسة `Guarded Audio` أو إيقافها:

- التطبيق يقرأ الحالة الخام من الطبقة الأصلية Android.
- يمرر الحالة إلى `guarded_audio_classifier.dart`.
- يحفظ الميزات والتوقع الحالي كعينة تدريب حقيقية.
- يمنع التكرار عبر signature للجلسة نفسها.

## كيف يوسمها المستخدم

داخل شاشة `Rescue`:

- تظهر بطاقة `حكم الحراسة الصوتية`.
- أسفلها قسم `وسم آخر جلسة محفوظة`.
- يمكن للمستخدم وسم الجلسة كواحدة من:
  - `lighter_like_pattern`
  - `restless_window`
  - `steady_breathing`
  - `cough_stress`
  - `high_arousal_audio`
  - `ambient_or_unclear`

هذا الوسم لا يغير السلوك الحالي فقط، بل يغذي dataset الجولة القادمة.

## كيف يصدّر dataset

من شاشة `Lab`:

- بطاقة `حلقة إعادة تدريب الصوت`
- تعرض:
  - إجمالي الجلسات
  - الجلسات الموسومة
  - آخر حكم متوقع
- زر:
  - `تصدير dataset موسوم`

على Android:

- الملف يُحفظ إلى `Downloads` عبر `MediaStore` عند الإمكان.
- الاسم الافتراضي:
  - `nafas_guarded_audio_labeled.csv`

## صيغة CSV

الأعمدة المصدّرة:

- `captured_at`
- `started_at`
- `ended_at`
- `session_duration_seconds`
- `average_amplitude`
- `peak_amplitude`
- `lighter_like_spikes`
- `cough_like_bursts`
- `steady_breath_cycles`
- `restlessness_bursts`
- `audio_risk_score`
- `sample_count`
- `predicted_label`
- `predicted_confidence`
- `prediction_source`
- `recommended_action`
- `confirmed_label`

## كيف يعيد المطور تدريب النموذج

السكربت:

- `app/tool/generate_guarded_audio_tflite.py`

الآن يدعم:

- بيانات اصطناعية أساسية
- ودمج dataset حقيقي عبر:

```bash
python tool/generate_guarded_audio_tflite.py --real-data path/to/nafas_guarded_audio_labeled.csv
```

خيارات إضافية:

```bash
python tool/generate_guarded_audio_tflite.py --real-data path/to/file.csv --real-weight 8
```

`real-weight` يزيد وزن العينات الحقيقية عند الدمج مع البيانات الاصطناعية.

## أفضل ممارسة تشغيلية

1. فعّل `Guarded Audio`.
2. اجمع 20 إلى 50 جلسة حقيقية على الأقل.
3. لا تعتمد على الجلسات غير الموسومة.
4. وسّم فقط الجلسات الواضحة.
5. صدّر CSV.
6. أعد التدريب بالسكربت.
7. استبدل:
   - `assets/models/guarded_audio_classifier.tflite`
8. أعد بناء التطبيق.

## القيود الحالية

- ما يزال النموذج يعتمد على ميزات engineered audio وليس waveform model كامل.
- لا يوجد تدريب on-device داخل التطبيق نفسه.
- جودة النموذج تعتمد مباشرة على جودة الوسوم اليدوية.

## لماذا هذا كافٍ الآن

لأن هذه المرحلة تغلق الحلقة الصحيحة عمليًا:

- جمع حقيقي
- وسم حقيقي
- تصدير حقيقي
- إعادة تدريب قابلة للتكرار

وهذا يحول الحراسة الصوتية من demo ذكي إلى مسار تحسين فعلي قابل للتراكم.
