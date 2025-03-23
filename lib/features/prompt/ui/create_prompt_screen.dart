import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/prompt_provider.dart';
import '../providers/theme_provider.dart';

class CreatePromptScreen extends StatefulWidget {
  const CreatePromptScreen({Key? key}) : super(key: key);

  @override
  State<CreatePromptScreen> createState() => _CreatePromptScreenState();
}

class _CreatePromptScreenState extends State<CreatePromptScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PromptProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('AI Image Creator'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            isDark ? CupertinoIcons.sun_max : CupertinoIcons.moon,
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),
      ),
      child: SafeArea(
        child: Consumer<PromptProvider>(
          builder: (context, promptProvider, child) {
            switch (promptProvider.state) {
              case PromptState.loading:
                return const Center(
                  child: CupertinoActivityIndicator(radius: 20),
                );

              case PromptState.error:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_circle,
                        size: 50,
                        color: CupertinoColors.systemRed,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? CupertinoColors.white : CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton.filled(
                        onPressed: () => _controller.text.isNotEmpty
                            ? promptProvider.generateImage(_controller.text)
                            : null,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );

              case PromptState.success:
                return _buildSuccessUI(promptProvider, isDark);

              case PromptState.initial:
              default:
                return _buildInputUI(promptProvider, isDark);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSuccessUI(PromptProvider promptProvider, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.maxFinite,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? CupertinoColors.systemGrey.withOpacity(0.3)
                      : CupertinoColors.systemGrey.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
              image: DecorationImage(
                image: MemoryImage(promptProvider.imageData!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: CupertinoButton.filled(
                  onPressed: promptProvider.isSaving
                      ? null
                      : () async {
                          final result = await promptProvider.saveImageToGallery();
                          if (result) {
                            _showSuccessDialog();
                          } else {
                            _showErrorDialog();
                          }
                        },
                  child: promptProvider.isSaving
                      ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                      : const Text('Save to Gallery'),
                ),
              ),
            ],
          ),
        ),
        _buildPromptInput(promptProvider, isDark),
      ],
    );
  }

  Widget _buildInputUI(PromptProvider promptProvider, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.photo_on_rectangle,
                  size: 80,
                  color: isDark
                      ? CupertinoColors.systemIndigo.withOpacity(0.8)
                      : CupertinoColors.systemIndigo,
                ),
                const SizedBox(height: 16),
                Text(
                  "Create beautiful AI images",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? CupertinoColors.white : CupertinoColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "Enter a detailed description to generate unique images",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildPromptInput(promptProvider, isDark),
      ],
    );
  }

  Widget _buildPromptInput(PromptProvider promptProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Describe your image",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _controller,
            placeholder: "E.g., A serene mountain landscape at sunset",
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? CupertinoColors.systemGrey6 : CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? CupertinoColors.systemGrey4
                    : CupertinoColors.systemGrey3,
              ),
            ),
            style: TextStyle(
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            ),
            clearButtonMode: OverlayVisibilityMode.editing,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(vertical: 14),
              borderRadius: BorderRadius.circular(12),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  promptProvider.generateImage(_controller.text);
                  FocusScope.of(context).unfocus();
                }
              },
              child: const Text(
                'Generate',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: const Text('Image saved to gallery successfully.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: const Text('Failed to save image. Please check app permissions.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
