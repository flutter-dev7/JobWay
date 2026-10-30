import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme_extension.dart';
import '../feedback/app_snackbar.dart';

// Достаёт код из вставленного текста: сначала ищет подряд идущие цифры нужной длины,
// иначе берёт все цифры (например, «123 456»)
String _extractCode(String text, int length) {
  final exact = RegExp('\\d{$length}').firstMatch(text)?.group(0);
  if (exact != null) return exact;

  final digits = text.replaceAll(RegExp(r'\D'), '');
  return digits.length > length ? digits.substring(0, length) : digits;
}

class _OtpFormatter extends TextInputFormatter {
  final int length;

  const _OtpFormatter(this.length);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final code = _extractCode(newValue.text, length);

    return TextEditingValue(
      text: code,
      selection: TextSelection.collapsed(offset: code.length),
    );
  }
}

class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;

  // Поле берёт фокус само: клавиатура остаётся открытой при смене шага
  final bool autofocus;

  // Кнопка «Вставить код» под клетками
  final bool showPasteButton;

  const OtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.autofocus = true,
    this.showPasteButton = true,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final Listenable _changes;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _changes = Listenable.merge([_controller, _focusNode]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Фокус не снимаем: клавиатура остаётся открытой, пока следующий экран не возьмёт фокус
  void _onChanged(String value) {
    if (value.length == widget.length) widget.onCompleted(value);
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final code = _extractCode(data?.text ?? '', widget.length);

    if (code.isEmpty) {
      AppSnackbar.showError('В буфере обмена нет кода');
      return;
    }

    _controller.value = TextEditingValue(
      text: code,
      selection: TextSelection.collapsed(offset: code.length),
    );
    _focusNode.requestFocus();
    _onChanged(code);
  }

  Widget _buildCells() {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _changes,
      builder: (context, _) {
        final text = _controller.text;
        final hasFocus = _focusNode.hasFocus;
        final activeIndex = text.length >= widget.length
            ? widget.length - 1
            : text.length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (index) {
            final isActive = hasFocus && index == activeIndex;

            return Container(
              width: 46,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? colors.textPrimary : colors.border,
                  width: isActive ? 1.4 : 1,
                ),
              ),
              child: Text(
                index < text.length ? text[index] : '',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // Настоящее поле лежит поверх клеток: текст прозрачный, но нажатие,
  // долгое нажатие (меню «Вставить») и Backspace работают как в обычном поле
  Widget _buildField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.number,
      inputFormatters: [_OtpFormatter(widget.length)],
      autocorrect: false,
      enableSuggestions: false,
      showCursor: false,
      cursorColor: Colors.transparent,
      expands: true,
      maxLines: null,
      minLines: null,
      style: const TextStyle(color: Colors.transparent),
      decoration: const InputDecoration(
        filled: false,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
      onChanged: _onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 54,
          child: Stack(
            children: [
              _buildCells(),
              Positioned.fill(child: _buildField()),
            ],
          ),
        ),
        if (widget.showPasteButton)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: _paste,
              style: TextButton.styleFrom(
                foregroundColor: context.accentColor,
              ),
              icon: const Icon(Icons.content_paste_rounded, size: 18),
              label: const Text(
                'Вставить код',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }
}