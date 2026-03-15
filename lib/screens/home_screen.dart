import 'package:fast_api_and_flutter/provider/theam_provider.dart';
import 'package:fast_api_and_flutter/utils/banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../provider/task_provider.dart';

class _AppColors {
  final Color bg;
  final Color surface;
  final Color card;
  final Color input;
  final Color hi;
  final Color mid;
  final Color lo;
  final Color divider;

  static const accent = Color(0xFF0EA5E9);
  static const accentDim = Color(0xFF0284C7);
  static const accentGlow = Color(0x220EA5E9);
  static const danger = Color(0xFFEF4444);
  static const editColor = Color(0xFF6366F1);

  const _AppColors._({
    required this.bg,
    required this.surface,
    required this.card,
    required this.input,
    required this.hi,
    required this.mid,
    required this.lo,
    required this.divider,
  });

  factory _AppColors.dark() => const _AppColors._(
    bg: Color(0xFF0E1117),
    surface: Color(0xFF161B22),
    card: Color(0xFF1C2333),
    input: Color(0xFF21262D),
    hi: Color(0xFFE6EDF3),
    mid: Color(0xFF8B949E),
    lo: Color(0xFF484F58),
    divider: Color(0xFF21262D),
  );

  factory _AppColors.light() => const _AppColors._(
    bg: Color(0xFFF0F4F8),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    input: Color(0xFFEEF2F6),
    hi: Color(0xFF0F172A),
    mid: Color(0xFF64748B),
    lo: Color(0xFFCBD5E1),
    divider: Color(0xFFE2E8F0),
  );

  factory _AppColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _AppColors.dark() : _AppColors.light();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSending = false;

  final Set<int> _loadingIds = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    });
  }

  @override
  void dispose() {
    _taskCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isLoading(int id) => _loadingIds.contains(id);

  void _markLoading(int id) => setState(() => _loadingIds.add(id));
  void _clearLoading(int id) => setState(() => _loadingIds.remove(id));

  Future<void> _addTask(TaskProvider tp) async {
    final text = _taskCtrl.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() => _isSending = true);

    try {
      await tp.addTask(text);
      _taskCtrl.clear();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _deleteTask(TaskProvider tp, int id) async {
    final confirmed = await _confirmSheet(
      icon: Icons.delete_rounded,
      iconColor: _AppColors.danger,
      title: 'Delete task?',
      message: 'This action cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: _AppColors.danger,
    );
    if (!confirmed) return;

    _markLoading(id);
    try {
      await tp.deleteTask(id);
    } finally {
      _clearLoading(id);
    }
  }

  void _showEditDialog(TaskProvider tp, int id, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => _EditDialog(
        controller: ctrl,
        onUpdate: (newText) async {
          _markLoading(id);
          try {
            await tp.updateTask(id, newText);
          } finally {
            _clearLoading(id);
          }
        },
      ),
    );
  }

  Future<bool> _confirmSheet({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    final c = _AppColors.of(context);

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: c.lo,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),

            Text(
              title,
              style: TextStyle(
                color: c.hi,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(color: c.mid, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.lo),
                      foregroundColor: c.mid,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  void _showThemePicker(ThemeProvider tp) {
    final c = _AppColors.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: c.lo,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'Appearance',
                style: TextStyle(
                  color: c.hi,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            _ThemeTile(
              icon: Icons.nights_stay_rounded,
              iconBg: const Color(0xFF1D2D50),
              iconColor: const Color(0xFF93C5FD),
              label: 'Dark',
              subtitle: 'Gentle on the eyes at night',
              selected: tp.themeMode == ThemeMode.dark,
              colors: c,
              onTap: () async {
                await tp.setTheme('dark');

                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),

            _ThemeTile(
              icon: Icons.wb_sunny_rounded,
              iconBg: const Color(0xFFFFF3CD),
              iconColor: const Color(0xFFF59E0B),
              label: 'Light',
              subtitle: 'Bright and crisp',
              selected: tp.themeMode == ThemeMode.light,
              colors: c,
              onTap: () async {
                await tp.setTheme('light');

                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<TaskProvider>(context);
    final them = Provider.of<ThemeProvider>(context);

    final tasks = tp.tasks;

    final c = _AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: c.bg,

        appBar: AppBar(
          backgroundColor: c.surface,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 20,

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task Manager',
                style: TextStyle(
                  color: c.hi,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                tasks.isEmpty
                    ? 'No tasks'
                    : '${tasks.length} task${tasks.length == 1 ? '' : 's'}',
                style: TextStyle(color: c.mid, fontSize: 12),
              ),
            ],
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: GestureDetector(
                onTap: () => _showThemePicker(them),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.input,
                    border: Border.all(color: c.lo),
                  ),
                  child: const Icon(
                    Icons.palette_rounded,
                    color: _AppColors.accent,
                    size: 19,
                  ),
                ),
              ),
            ),
          ],

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: c.divider),
          ),
        ),

        body: Column(
          children: [
            const InternetBanner(),
            Expanded(
              child: RefreshIndicator(
                color: _AppColors.accent,
                backgroundColor: c.surface,
                strokeWidth: 2.5,

                onRefresh: () => tp.fetchTasks(),
                child: tasks.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.28,
                          ),
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _AppColors.accentGlow,
                                  ),
                                  child: const Icon(
                                    Icons.checklist_rounded,
                                    color: _AppColors.accent,
                                    size: 34,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'All clear!',
                                  style: TextStyle(
                                    color: c.hi,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Add your first task below',
                                  style: TextStyle(color: c.mid, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 10, bottom: 100),
                        itemCount: tasks.length,
                        itemBuilder: (ctx, i) {
                          final task = tasks[i];
                          return _TaskTile(
                            key: ValueKey(task.id),
                            task: task,
                            isLoading: _isLoading(task.id),
                            colors: c,
                            onEdit: () =>
                                _showEditDialog(tp, task.id, task.description),
                            onDelete: () => _deleteTask(tp, task.id),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),

        bottomNavigationBar: _InputBar(
          controller: _taskCtrl,
          focusNode: _focusNode,
          isSending: _isSending,
          colors: c,
          onSend: () => _addTask(tp),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final dynamic task;
  final bool isLoading;
  final _AppColors colors;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskTile({
    super.key,
    required this.task,
    required this.isLoading,
    required this.colors,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _swipeBg({
    required Color color,
    required IconData icon,
    required Color iconColor,
    required String label,
    required AlignmentGeometry align,
    required EdgeInsetsGeometry pad,
  }) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
    ),
    alignment: align,
    padding: pad,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: iconColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = colors;

    return Dismissible(
      key: ValueKey('d_${task.id}'),

      background: _swipeBg(
        color: _AppColors.editColor.withOpacity(0.15),
        icon: Icons.edit_rounded,
        iconColor: _AppColors.editColor,
        label: 'Edit',
        align: Alignment.centerLeft,
        pad: const EdgeInsets.only(left: 28),
      ),

      secondaryBackground: _swipeBg(
        color: _AppColors.danger.withOpacity(0.15),
        icon: Icons.delete_rounded,
        iconColor: _AppColors.danger,
        label: 'Delete',
        align: Alignment.centerRight,
        pad: const EdgeInsets.only(right: 28),
      ),

      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          onEdit();
        } else {
          onDelete();
        }
        return false;
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isLoading ? _AppColors.accentGlow : c.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isLoading ? _AppColors.accent.withOpacity(0.4) : c.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),

            leading: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _AppColors.accentGlow,
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(9),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _AppColors.accent,
                      ),
                    )
                  : const Icon(
                      Icons.radio_button_unchecked,
                      color: _AppColors.accent,
                      size: 18,
                    ),
            ),

            title: Text(
              task.description,
              style: TextStyle(
                color: isLoading ? c.mid : c.hi,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  color: _AppColors.editColor,
                  onTap: onEdit,
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: Icons.delete_outline_rounded,
                  color: _AppColors.danger,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.10),
      ),
      child: Icon(icon, color: color, size: 16),
    ),
  );
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final _AppColors colors;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.colors,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;

    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      color: c.surface,
      padding: EdgeInsets.fromLTRB(12, 10, 12, 25 + bottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                color: c.input,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: c.lo),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Icon(Icons.task_alt_rounded, color: c.mid, size: 20),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: TextStyle(color: c.hi, fontSize: 15),
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Add a task…',
                        hintStyle: TextStyle(color: c.mid, fontSize: 15),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          GestureDetector(
            onTap: isSending ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_AppColors.accent, _AppColors.accentDim],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _AppColors.accent.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditDialog extends StatelessWidget {
  final TextEditingController controller;

  final Future<void> Function(String) onUpdate;

  const _EditDialog({required this.controller, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final c = _AppColors.of(context);

    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _AppColors.editColor.withOpacity(0.12),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: _AppColors.editColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit Task',
                  style: TextStyle(
                    color: c.hi,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: c.input,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.lo),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(color: c.hi, fontSize: 15),
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  hintText: 'Update task…',
                  hintStyle: TextStyle(color: c.mid),
                ),
              ),
            ),
            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.lo),
                      foregroundColor: c.mid,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;
                      Navigator.pop(context);
                      await onUpdate(text);
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool selected;
  final _AppColors colors;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _AppColors.accentGlow : c.input,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _AppColors.accent.withOpacity(0.5) : c.lo,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? _AppColors.accent : c.hi,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(subtitle, style: TextStyle(color: c.mid, fontSize: 12)),
                ],
              ),
            ),

            if (selected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _AppColors.accent,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
