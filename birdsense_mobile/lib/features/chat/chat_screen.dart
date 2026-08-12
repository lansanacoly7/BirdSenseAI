import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final String? initialQuestion;
  
  const ChatScreen({super.key, this.initialQuestion});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isAiTyping = false;
  WebSocketChannel? _channel;

  static const List<String> _suggestedQuestions = [
    '🦅 Quels rapaces trouve-t-on au Sénégal ?',
    '🌍 Quels oiseaux sont menacés en Afrique de l\'Ouest ?',
    '🎵 Comment identifier un oiseau par son chant ?',
    '🪺 Quelle est la saison de nidification au Djoudj ?',
    '📸 Conseils pour photographier les flamants roses',
    '🧬 Différence entre vautour et aigle ?',
  ];

  late AnimationController _headerAnimController;
  late Animation<double> _headerPulse;

  @override
  void initState() {
    super.initState();
    
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _headerPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeInOut),
    );
    
    _connectWebSocket();
    
    // Welcome message
    _messages.add({
      'isUser': false,
      'text': 'Bonjour ! 👋 Je suis votre assistant ornithologique propulsé par l\'IA. Posez-moi n\'importe quelle question sur les oiseaux du Sénégal — identification, comportement, conservation, chants, habitats...',
      'isTyping': false,
      'timestamp': DateTime.now(),
    });
    
    // If an initial question was provided (e.g., "Interroger l'IA sur cet oiseau")
    if (widget.initialQuestion != null && widget.initialQuestion!.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _textController.text = widget.initialQuestion!;
        _sendMessage();
      });
    }
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8000/api/v1/chat/stream'),
      );
      _channel!.stream.listen((message) {
        if (!mounted) return;
        final data = jsonDecode(message);
        if (data['chunk'] != null) {
          setState(() {
            _isAiTyping = true;
            if (_messages.isEmpty || _messages[0]['isUser'] == true || _messages[0]['isFinished'] == true) {
               _messages.insert(0, {
                  'isUser': false,
                  'text': data['chunk'],
                  'isTyping': false, // let's not use typewriter, we are streaming word by word
                  'isFinished': false,
                  'timestamp': DateTime.now(),
               });
            } else {
               _messages[0]['text'] += data['chunk'];
            }
          });
        }
        if (data['done'] == true) {
          setState(() {
            if (_messages.isNotEmpty && _messages[0]['isUser'] == false) {
              _messages[0]['isFinished'] = true;
            }
            _isAiTyping = false;
          });
        }
      }, onError: (error) {
        if (!mounted) return;
        setState(() {
           _isAiTyping = false;
           _messages.insert(0, {
             'isUser': false,
             'text': '⚠️ Une erreur de connexion est survenue. Le serveur IA est indisponible.',
             'isTyping': false,
             'isFinished': true,
             'timestamp': DateTime.now(),
           });
        });
      });
    } catch (e) {
      debugPrint("WebSocket error: $e");
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _headerAnimController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? overrideText]) {
    final text = overrideText ?? _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(0, {
        'isUser': true,
        'text': text,
        'isTyping': false,
        'isFinished': true,
        'timestamp': DateTime.now(),
      });
      _isAiTyping = true;
    });

    _textController.clear();
    FocusScope.of(context).unfocus();

    if (_channel != null) {
      _channel!.sink.add(text);
    } else {
      _connectWebSocket();
      _channel?.sink.add(text);
    }
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    setState(() {
      _messages.insert(0, {
        'isUser': true,
        'text': '',
        'imagePath': image.path,
        'isTyping': false,
        'isFinished': true,
        'timestamp': DateTime.now(),
      });
      _isAiTyping = true;
    });

    // We can send image over WebSocket if backend supports it. For now, send a text prompt indicating an image.
    if (_channel != null) {
      _channel!.sink.add("J'ai importé une image, peux-tu me parler du Pélican ou du Flamant rose ?");
    } else {
      _connectWebSocket();
      _channel?.sink.add("J'ai importé une image, peux-tu me parler du Pélican ou du Flamant rose ?");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Premium Glassmorphic Header
          _buildHeader(isDark, surfaceColor, borderColor, textPrimary, textSecondary),
          
          // Messages Area
          Expanded(
            child: _messages.length <= 1 && !_isAiTyping
                ? _buildWelcomeState(isDark, surfaceColor, borderColor, textPrimary, textSecondary, textMuted)
                : _buildMessagesList(isDark, surfaceColor, borderColor, textPrimary, textSecondary),
          ),
          
          // AI Typing Indicator
          if (_isAiTyping) _buildTypingIndicator(isDark, surfaceColor),
          
          // Input Area
          _buildInputArea(isDark, surfaceColor, borderColor, textPrimary, textMuted),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color surfaceColor, Color borderColor, Color textPrimary, Color textSecondary) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          // AI Avatar with animated pulse
          AnimatedBuilder(
            animation: _headerPulse,
            builder: (context, child) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryAction,
                      AppColors.secondaryAction,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryAction.withOpacity(0.3 * _headerPulse.value),
                      blurRadius: 16 * _headerPulse.value,
                      spreadRadius: 2 * _headerPulse.value,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              );
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assistant Ornithologique IA',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAction,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryAction.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'En ligne • Gemini Pro',
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Context Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryAction.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryAction.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco_rounded, size: 14, color: AppColors.primaryAction),
                const SizedBox(width: 4),
                Text(
                  '660+ espèces',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryAction,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeState(bool isDark, Color surfaceColor, Color borderColor, Color textPrimary, Color textSecondary, Color textMuted) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Welcome message bubble
          _buildMessageBubble(
            _messages.last['text'],
            false,
            false,
            () {},
            isDark,
            surfaceColor,
            borderColor,
            textPrimary,
            textSecondary,
          ),
          
          const SizedBox(height: 32),
          
          // Suggestions Section
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 14),
              child: Text(
                'Suggestions pour vous',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          
          // Suggestion Chips Grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _suggestedQuestions.map((q) {
              return GestureDetector(
                onTap: () => _sendMessage(q),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    q,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Capabilities Cards
          _buildCapabilitiesSection(isDark, surfaceColor, borderColor, textPrimary, textSecondary, textMuted),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesSection(bool isDark, Color surfaceColor, Color borderColor, Color textPrimary, Color textSecondary, Color textMuted) {
    final capabilities = [
      {'icon': Icons.search_rounded, 'title': 'Identification', 'desc': 'Identifiez n\'importe quel oiseau par description ou photo'},
      {'icon': Icons.music_note_rounded, 'title': 'Bioacoustique', 'desc': 'Analyse des chants et signatures sonores'},
      {'icon': Icons.shield_rounded, 'title': 'Conservation', 'desc': 'Statuts UICN, menaces et actions de protection'},
      {'icon': Icons.map_rounded, 'title': 'Géolocalisation', 'desc': 'Habitats, routes migratoires et sites d\'observation'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 14),
          child: Text(
            'Capacités de l\'IA',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textSecondary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: capabilities.map((cap) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAction.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cap['icon'] as IconData, size: 18, color: AppColors.primaryAction),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cap['title'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cap['desc'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: textMuted,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMessagesList(bool isDark, Color surfaceColor, Color borderColor, Color textPrimary, Color textSecondary) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        if (msg['imagePath'] != null) {
          return _buildImageBubble(
            msg['imagePath'],
            isDark,
            surfaceColor,
            borderColor,
            textSecondary,
          );
        }
        return _buildMessageBubble(
          msg['text'],
          msg['isUser'],
          msg['isTyping'] ?? false,
          () {
            setState(() {
              _messages[index]['isTyping'] = false;
            });
          },
          isDark,
          surfaceColor,
          borderColor,
          textPrimary,
          textSecondary,
        );
      },
    );
  }

  Widget _buildMessageBubble(
    String text,
    bool isUser,
    bool isTyping,
    VoidCallback onFinished,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar
          if (!isUser) ...[
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 10, top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryAction, AppColors.secondaryAction],
                ),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
          ],
          
          // Message Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppColors.primaryAction 
                    : surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: Radius.circular(isUser ? 22 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 22),
                ),
                border: isUser ? null : Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: isUser 
                        ? AppColors.primaryAction.withOpacity(0.25)
                        : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              child: isTyping
                  ? TypewriterText(
                      text: text,
                      onFinished: onFinished,
                      textColor: isUser ? Colors.white : textPrimary,
                    )
                  : MarkdownBody(
                      data: text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: isUser ? Colors.white : textPrimary,
                          height: 1.5,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
            ),
          ),
          
          // User Avatar
          if (isUser) ...[
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(left: 10, top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBorder,
              ),
              child: Icon(Icons.person_rounded, color: textSecondary, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageBubble(
    String imagePath,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryAction,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAction.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                    child: Image.network(
                      imagePath,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.white.withOpacity(0.1),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_rounded, color: Colors.white70, size: 48),
                              SizedBox(height: 8),
                              Text('Image importée', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white70, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Analyser cet oiseau',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(left: 10, top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBorder,
            ),
            child: Icon(Icons.person_rounded, color: textSecondary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark, Color surfaceColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primaryAction, AppColors.secondaryAction],
              ),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
                const SizedBox(width: 10),
                Text(
                  'L\'IA réfléchit...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primaryAction.withOpacity(0.4 + (0.6 * value)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea(bool isDark, Color surfaceColor, Color borderColor, Color textPrimary, Color textMuted) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment Button
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: Icon(Icons.add_photo_alternate_outlined, 
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, size: 20),
              onPressed: _pickAndSendImage,
              tooltip: 'Joindre une photo d\'oiseau',
            ),
          ),
          const SizedBox(width: 10),
          
          // Text Input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _textController,
                style: TextStyle(color: textPrimary, fontSize: 14),
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Posez une question sur les oiseaux...',
                  hintStyle: TextStyle(color: textMuted, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          
          // Send Button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryAction, AppColors.secondaryAction],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAction.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Typewriter Animation Widget ---
class TypewriterText extends StatefulWidget {
  final String text;
  final VoidCallback onFinished;
  final Color textColor;

  const TypewriterText({
    super.key,
    required this.text,
    required this.onFinished,
    this.textColor = Colors.white,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: _displayedText,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: widget.textColor,
          height: 1.5,
          fontSize: 14,
        ),
      ),
    );
  }
}
