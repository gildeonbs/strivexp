import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/router.dart';
import '../viewmodels/birthday_viewmodel.dart';

class BirthdayPage extends ConsumerStatefulWidget {
  const BirthdayPage({super.key});

  @override
  ConsumerState<BirthdayPage> createState() => _BirthdayPageState();
}

class _BirthdayPageState extends ConsumerState<BirthdayPage> {
  DateTime? _selectedDate;

  static const Color _textColor = Color.fromARGB(255, 112, 114, 113);
  static const Color _fieldColor = Color.fromARGB(255, 231, 231, 231);
  static const Color _buttonBlue = Color.fromARGB(255, 132, 186, 220);
  static const Color _yellowStriveXP = Color.fromARGB(255, 244, 191, 59);

  // Constraints
  final DateTime _minDate = DateTime(1900, 1, 1);
  final DateTime _maxDate = DateTime.now();

  void _onNext() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your birthday'),
          backgroundColor: _yellowStriveXP,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    
    final d = _selectedDate!.day;
    final m = _selectedDate!.month;
    final y = _selectedDate!.year;

    ref.read(birthdayViewModelProvider.notifier).submitBirthday(d, m, y);
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done', style: TextStyle(color: _buttonBlue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate ?? DateTime(2000, 1, 1),
                  minimumDate: _minDate,
                  maximumDate: _maxDate,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuta estado para navegação/feedback
    ref.listen(birthdayViewModelProvider, (previous, next) {
      next.when(
        data: (_) {
          // Sucesso: Vai para a tela de Nome
          context.push(AppRoutes.signUpName);
        },
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        },
        loading: () {},
      );
    });

    final state = ref.watch(birthdayViewModelProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: SvgPicture.asset(
                    'assets/images/back_arrow.svg',
                    width: 24,
                    height: 24,
                    placeholderBuilder: (_) => const Icon(Icons.arrow_back),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Title
              const Text(
                "What's your birthday?",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: _textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // 3. Date Selector (Line style)
              GestureDetector(
                onTap: _showDatePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black12,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? "Select your birthday"
                            : DateFormat('MMMM d, yyyy').format(_selectedDate!),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          color: _selectedDate == null ? Colors.grey : _textColor,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: _buttonBlue, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. Descriptive Text
              const Text(
                "This is just to confirm your age. Your information is kept private.",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: _textColor,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 40),

              // 5. NEXT Button
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: isLoading ? null : _onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: _buttonBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'NEXT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
