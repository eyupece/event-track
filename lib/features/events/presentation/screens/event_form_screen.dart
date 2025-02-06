import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/event_model.dart';

// Form validasyonları için sabitler
const int _titleMaxLength = 50;
const int _descriptionMaxLength = 500;
const int _locationMaxLength = 50;
const int _notesMaxLength = 500;

class EventFormValidator {
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Başlık alanı boş bırakılamaz';
    }
    if (value.length < 3) {
      return 'Başlık en az 3 karakter olmalıdır';
    }
    if (value.length > _titleMaxLength) {
      return 'Başlık en fazla $_titleMaxLength karakter olabilir';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.length > _descriptionMaxLength) {
      return 'Açıklama en fazla $_descriptionMaxLength karakter olabilir';
    }
    return null;
  }

  static String? validateLocation(String? value) {
    if (value != null && value.length > _locationMaxLength) {
      return 'Konum en fazla $_locationMaxLength karakter olabilir';
    }
    return null;
  }

  static String? validateNotes(String? value) {
    if (value != null && value.length > _notesMaxLength) {
      return 'Notlar en fazla $_notesMaxLength karakter olabilir';
    }
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen bir kategori seçin';
    }
    return null;
  }
}

class EventFormScreen extends StatefulWidget {
  final Event? event; // Düzenleme modu için event parametresi

  const EventFormScreen({
    super.key,
    this.event,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'Konser';
  String? _titleError;
  String? _categoryError;
  bool _isLoading = false;

  bool get _isEditMode => widget.event != null;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Konser',
      'icon': Icons.music_note,
      'color': const Color(0xFFFF6B6B),
    },
    {
      'name': 'Teknoloji',
      'icon': Icons.computer,
      'color': const Color(0xFFFFB84D),
    },
    {
      'name': 'Sinema',
      'icon': Icons.movie,
      'color': const Color(0xFF4ECDC4),
    },
    {
      'name': 'Tiyatro',
      'icon': Icons.theater_comedy,
      'color': const Color(0xFF9B59B6),
    },
    {
      'name': 'Spor',
      'icon': Icons.sports_soccer,
      'color': const Color(0xFF2ECC71),
    },
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      // Düzenleme modunda form alanlarını doldur
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.location ?? '';
      _notesController.text = widget.event!.notes ?? '';
      _selectedDate = widget.event!.date;
      _selectedTime = widget.event!.time;
      _selectedCategory = widget.event!.category;
    } else {
      // Ekleme modunda varsayılan değerler
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    bool isValid = true;

    // Başlık kontrolü
    final titleError = EventFormValidator.validateTitle(_titleController.text);
    setState(() => _titleError = titleError);
    if (titleError != null) isValid = false;

    // Kategori kontrolü
    final categoryError =
        EventFormValidator.validateCategory(_selectedCategory);
    setState(() => _categoryError = categoryError);
    if (categoryError != null) isValid = false;

    return isValid;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    IconData? prefixIcon,
    String? Function(String?)? validator,
    String? errorText,
  }) {
    final int? maxLength = label == 'Başlık'
        ? _titleMaxLength
        : label == 'Açıklama'
            ? _descriptionMaxLength
            : label == 'Konum'
                ? _locationMaxLength
                : label == 'Notlar'
                    ? _notesMaxLength
                    : null;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      maxLength: maxLength,
      buildCounter: (
        BuildContext context, {
        required int currentLength,
        required bool isFocused,
        int? maxLength,
      }) {
        if (maxLength == null) return null;
        final remaining = maxLength - currentLength;
        final color = remaining < 20
            ? Colors.orange
            : remaining < 10
                ? Colors.red
                : Colors.white70;

        return Text(
          '$remaining karakter kaldı',
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        );
      },
      onChanged: (value) {
        if (validator != null) {
          setState(() {
            if (label == 'Başlık') {
              _titleError = validator(value);
            }
          });
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: errorText != null ? Colors.red : Colors.white24,
            width: errorText != null ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white12,
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tarih',
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          filled: true,
          fillColor: Colors.white12,
        ),
        child: Text(
          DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return InkWell(
      onTap: _selectTime,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Saat',
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.access_time, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          filled: true,
          fillColor: Colors.white12,
        ),
        child: Text(
          _selectedTime.format(context),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _showCategoryPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _categoryError != null ? Colors.red : Colors.white24,
                width: _categoryError != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _categories.firstWhere(
                          (c) => c['name'] == _selectedCategory)['icon']
                      as IconData,
                  color: _categories.firstWhere(
                      (c) => c['name'] == _selectedCategory)['color'] as Color,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedCategory,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_categoryError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              _categoryError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _selectDate() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month - 1,
                        );
                      });
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TableCalendar(
                firstDay: DateTime(2023),
                lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
                focusedDay: _selectedDate,
                currentDay: DateTime.now(),
                selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerVisible: false,
                daysOfWeekHeight: 40,
                rowHeight: 40,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                  });

                  // Geçmiş tarih kontrolü
                  final now = DateTime.now();
                  final selectedDateTime = DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  );

                  if (selectedDateTime.isBefore(now)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            const Text('Dikkat: Geçmiş bir tarih seçtiniz'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }

                  Navigator.pop(context);
                },
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.white70),
                  selectedTextStyle: TextStyle(color: AppColors.primary),
                  todayTextStyle: TextStyle(color: Colors.white),
                  outsideTextStyle: TextStyle(color: Colors.white38),
                  selectedDecoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendStyle: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'İptal',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime.now();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Bugün',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Saat Seçin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeWheel(
                    value: _selectedTime.hour,
                    maxValue: 23,
                    onChanged: (value) {
                      setState(() {
                        _selectedTime = TimeOfDay(
                          hour: value,
                          minute: _selectedTime.minute,
                        );
                      });
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      ':',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildTimeWheel(
                    value: _selectedTime.minute,
                    maxValue: 59,
                    onChanged: (value) {
                      setState(() {
                        _selectedTime = TimeOfDay(
                          hour: _selectedTime.hour,
                          minute: value,
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'İptal',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTime = TimeOfDay.now();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Şimdi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Tamam',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeWheel({
    required int value,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      height: 150,
      width: 60,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListWheelScrollView.useDelegate(
        itemExtent: 40,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: value),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: maxValue + 1,
          builder: (context, index) {
            return Container(
              alignment: Alignment.center,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: index == value ? Colors.white : Colors.white60,
                  fontSize: index == value ? 24 : 20,
                  fontWeight:
                      index == value ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(76),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Kategori Seçin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category['name'] == _selectedCategory;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'] as String;
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (category['color'] as Color)
                            : (category['color'] as Color).withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : category['color'] as Color,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['name'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final event = Event(
        id: _isEditMode
            ? widget.event!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        time: _selectedTime,
        category: _selectedCategory,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
        isCompleted: _isEditMode ? widget.event!.isCompleted : false,
      );

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.of(context).pop(event);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bir hata oluştu. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Etkinliği Düzenle' : 'Yeni Etkinlik'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitForm,
            child: Text(
              _isEditMode ? 'Güncelle' : 'Kaydet',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Hero(
              tag: _isEditMode ? 'event_${widget.event!.id}' : 'addEventHero',
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Başlık',
                      prefixIcon: Icons.title,
                      errorText: _titleError,
                      validator: EventFormValidator.validateTitle,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Açıklama',
                      maxLines: 3,
                      validator: EventFormValidator.validateDescription,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildTimeField(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _locationController,
              label: 'Konum',
              prefixIcon: Icons.location_on_outlined,
              validator: EventFormValidator.validateLocation,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _notesController,
              label: 'Notlar',
              maxLines: 3,
              validator: EventFormValidator.validateNotes,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
