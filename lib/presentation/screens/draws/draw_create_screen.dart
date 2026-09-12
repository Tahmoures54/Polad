import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/enums.dart';
import '../../blocs/draws/draw_form_cubit.dart';
import '../auth/auth_widgets.dart';

/// فرم ایجاد دوره قرعه‌کشی.
class DrawCreateScreen extends StatelessWidget {
  const DrawCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DrawFormCubit(),
      child: const _DrawCreateView(),
    );
  }
}

class _DrawCreateView extends StatefulWidget {
  const _DrawCreateView();

  @override
  State<_DrawCreateView> createState() => _DrawCreateViewState();
}

class _DrawCreateViewState extends State<_DrawCreateView> {
  late final TextEditingController _title;
  late final TextEditingController _prize;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DrawFormCubit>();
    _title = TextEditingController(text: cubit.state.title);
    _prize = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    _prize.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final cubit = context.read<DrawFormCubit>();
    final current = start ? cubit.state.startDate : cubit.state.endDate;
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.fromDateTime(current),
      firstDate: Jalali(1400, 1),
      lastDate: Jalali(1410, 12),
    );
    if (picked == null) return;
    final dt = picked.toDateTime();
    if (start) {
      cubit.startChanged(dt);
    } else {
      cubit.endChanged(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DrawFormCubit, DrawFormState>(
      listenWhen: (p, c) => p.error != c.error || p.success != c.success,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('دوره قرعه‌کشی ساخته شد')));
          context.pop();
        }
      },
      builder: (context, state) {
        final cubit = context.read<DrawFormCubit>();
        return Scaffold(
          appBar: AppBar(title: const Text('دوره جدید قرعه‌کشی')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'عنوان، جایزه و بازه دوره را مشخص کنید. انتخاب برنده بعداً با انیمیشن یا به‌صورت دستی انجام می‌شود.',
                style: TextStyle(color: AppColors.muted, height: 1.7),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _title,
                decoration: InputDecoration(labelText: 'عنوان دوره', errorText: state.titleError),
                onChanged: cubit.titleChanged,
              ),
              const SizedBox(height: 12),
              PersianNumberField(
                controller: _prize,
                label: 'مبلغ جایزه (تومان)',
                inputFormatters: [PersianAmountFormatter()],
                onChanged: cubit.prizeChanged,
              ),
              if (state.prizeError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(state.prizeError!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('شروع دوره'),
                subtitle: Text(jalaliDate(state.startDate)),
                trailing: const Icon(Icons.calendar_month_outlined, color: AppColors.navy),
                onTap: () => _pickDate(start: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('پایان دوره'),
                subtitle: Text(jalaliDate(state.endDate)),
                trailing: const Icon(Icons.calendar_month_outlined, color: AppColors.navy),
                onTap: () => _pickDate(start: false),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<DrawSelectionMode>(
                initialValue: state.mode,
                items: DrawSelectionMode.values
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.fa)))
                    .toList(),
                onChanged: (v) => cubit.modeChanged(v ?? state.mode),
                decoration: const InputDecoration(labelText: 'نحوه انتخاب برنده'),
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                label: 'ایجاد دوره',
                busy: state.busy,
                onPressed: cubit.submit,
              ),
            ],
          ),
        );
      },
    );
  }
}
