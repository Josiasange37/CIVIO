import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/pdf_generator.dart';

class DocumentGeneratorScreen extends StatefulWidget {
  const DocumentGeneratorScreen({super.key});

  @override
  State<DocumentGeneratorScreen> createState() => _DocumentGeneratorScreenState();
}

class _DocumentGeneratorScreenState extends State<DocumentGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(text: 'Fatima MBARGA');
  final TextEditingController _universityController = TextEditingController(text: 'Université de Yaoundé II');
  final TextEditingController _levelController = TextEditingController(text: 'Master 1');
  final TextEditingController _majorController = TextEditingController(text: 'Droit public');

  bool _generated = false;
  bool _loading = false;

  void _doGenerate() {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _generated = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivioColors.subtle,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: CivioColors.textPrimary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Rédiger', style: TextStyle(fontWeight: FontWeight.w800)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF222222), Color(0xFF444444)],
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 56),
                    child: Text(
                      'Générez une lettre officielle\nprête à imprimer',
                      style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(CivioSpacing.lg),
              child: _generated ? _buildPreview() : _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _formCard([
            _buildField('Nom complet', _nameController, 'Ex: Jean Dupont'),
            const SizedBox(height: CivioSpacing.xl),
            _buildField('Université / École', _universityController, 'Ex: UY1'),
            const SizedBox(height: CivioSpacing.xl),
            Row(
              children: [
                Expanded(child: _buildField('Niveau', _levelController, 'Master 1')),
                const SizedBox(width: CivioSpacing.md),
                Expanded(child: _buildField('Filière', _majorController, 'Droit')),
              ],
            ),
          ]),
          const SizedBox(height: CivioSpacing.xxl),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _loading ? null : _doGenerate,
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Générer le PDF officiel'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(CivioSpacing.xl),
      decoration: BoxDecoration(
        color: CivioColors.canvas,
        borderRadius: BorderRadius.circular(CivioRadius.lg),
        boxShadow: CivioShadows.md,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: CivioSpacing.sm),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(CivioSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CivioColors.successLight, CivioColors.successLight.withValues(alpha: 0.5)],
            ),
            borderRadius: BorderRadius.circular(CivioRadius.lg),
            border: Border.all(color: CivioColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: CivioColors.success,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white),
              ),
              const SizedBox(width: CivioSpacing.lg),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Document prêt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('Aperçu ci-dessous', style: TextStyle(color: CivioColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: CivioSpacing.lg),
        Container(
          height: 360,
          width: double.infinity,
          padding: const EdgeInsets.all(CivioSpacing.xl),
          decoration: BoxDecoration(
            color: CivioColors.canvas,
            borderRadius: BorderRadius.circular(CivioRadius.lg),
            boxShadow: CivioShadows.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    '${_nameController.text}\nYaoundé, le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, color: CivioColors.textSecondary),
                  ),
                ),
                const SizedBox(height: CivioSpacing.lg),
                const Text('DEMANDE DE BOURSE NATIONALE', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: CivioSpacing.lg),
                Text(
                  'Je soussignée ${_nameController.text}, étudiante en ${_levelController.text}…',
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: CivioSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _generated = false),
                child: const Text('Modifier'),
              ),
            ),
            const SizedBox(width: CivioSpacing.md),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final bytes = await PdfGenerator.generateOfficialDocument(
                    title: 'DEMANDE DE BOURSE NATIONALE',
                    name: _nameController.text,
                    university: _universityController.text,
                    level: _levelController.text,
                    major: _majorController.text,
                    content: 'Je soussignée ${_nameController.text}…',
                  );
                  await PdfGenerator.saveAndShare(bytes, 'demande_bourse_civio.pdf');
                },
                icon: const Icon(Icons.download_outlined),
                label: const Text('Télécharger'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
