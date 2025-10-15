import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common_widgets.dart';

class AIAdvisorScreen extends ConsumerStatefulWidget {
  const AIAdvisorScreen({super.key});

  @override
  ConsumerState<AIAdvisorScreen> createState() => _AIAdvisorScreenState();
}

class _AIAdvisorScreenState extends ConsumerState<AIAdvisorScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  
  // Replace with your actual Gemini API key
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _initializeAI();
    _sendWelcomeMessage();
  }

  void _initializeAI() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
  }

  void _sendWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: 'Hello! 👋 I\'m your AI Tax Advisor for Nepal.\n\n'
            'I can help you with:\n'
            '• Understanding Nepal tax laws\n'
            '• Tax optimization strategies\n'
            '• Deduction eligibility\n'
            '• Tax filing guidance\n\n'
            'How can I assist you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Get user context for better responses
      final context = _getUserContext();
      
      // Create context-aware prompt
      final prompt = _createPrompt(text, context);

      // Get AI response (using Gemini or fallback to mock)
      final response = await _getAIResponse(prompt);

      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isTyping = false);
      
      // Add error message
      setState(() {
        _messages.add(ChatMessage(
          text: 'I apologize, but I encountered an error. Please try again or rephrase your question.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  String _getUserContext() {
    final totalIncome = ref.read(totalIncomeProvider);
    final totalExpense = ref.read(totalExpenseProvider);
    final user = ref.read(currentUserProvider);
    final incomeCount = ref.read(incomesProvider).value?.length ?? 0;
    final expenseCount = ref.read(expensesProvider).value?.length ?? 0;

    return '''
User Context:
- Marital Status: ${user?.isMarried == true ? 'Married' : 'Unmarried'}
- Total Annual Income: NPR ${totalIncome.toStringAsFixed(0)}
- Total Expenses: NPR ${totalExpense.toStringAsFixed(0)}
- Income Entries: $incomeCount
- Expense Entries: $expenseCount
- Location: Nepal
- Fiscal Year: 2081/82
''';
  }

  String _createPrompt(String userQuestion, String context) {
    return '''
You are a professional tax advisor specializing in Nepal's Income Tax Act 2058.

$context

User Question: $userQuestion

Instructions:
- Provide accurate, helpful advice specific to Nepal's tax system
- Reference Nepal Income Tax Act 2058 when applicable
- Use NPR (Nepali Rupees) for all amounts
- Be concise but comprehensive
- If unsure, recommend consulting a Chartered Accountant
- Use simple language, avoid excessive jargon
- Provide actionable advice when possible

Response:
''';
  }

  Future<String> _getAIResponse(String prompt) async {
    // Try to use Gemini AI
    if (_apiKey != 'YOUR_GEMINI_API_KEY_HERE') {
      try {
        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);
        return response.text ?? _getFallbackResponse(prompt);
      } catch (e) {
        debugPrint('Gemini API Error: $e');
        return _getFallbackResponse(prompt);
      }
    }
    
    // Fallback to mock responses
    return _getFallbackResponse(prompt);
  }

  String _getFallbackResponse(String prompt) {
    final question = prompt.toLowerCase();
    
    // Pattern matching for common questions
    if (question.contains('reduce') && question.contains('tax')) {
      return '''
Here are the top ways to reduce your tax in Nepal:

1. **Maximize Provident Fund (PF) Contributions**
   - Contribute to CIT, EPF, or SSF
   - Fully tax-deductible with no upper limit
   - Recommended: 10% of your salary

2. **Get Life Insurance**
   - Premium up to NPR 25,000 is deductible
   - Provides both protection and tax benefits

3. **Purchase Health Insurance**
   - Medical insurance up to NPR 25,000 is deductible
   - Covers you and your family

4. **Document Business Expenses**
   - Keep all receipts and bills
   - Claim legitimate business expenses
   - Categories include rent, utilities, travel, etc.

5. **Make Charitable Donations**
   - Donations to approved organizations
   - Deductible up to 10% of adjusted income

Would you like more details on any of these strategies?
''';
    }

    if (question.contains('deduction') && question.contains('missing')) {
      return '''
Based on your current financial data, here are deductions you might be missing:

**Common Missed Deductions:**

1. **Provident Fund (CIT/EPF/SSF)**
   - No upper limit
   - Check if you're contributing the maximum

2. **Insurance Premiums**
   - Life insurance: Up to NPR 25,000
   - Medical insurance: Up to NPR 25,000
   - Parent's health insurance: Up to NPR 25,000

3. **Business Expenses**
   - Office rent
   - Employee salaries
   - Utilities and communication
   - Travel and transport
   - Professional fees

4. **Remote Area Allowance**
   - If working in remote areas
   - Up to 50% of basic salary

5. **Medical Expenses**
   - Up to NPR 750 (individual) or NPR 1,000 (family)

Make sure you have proper documentation for all claims!
''';
    }

    if (question.contains('pf') || question.contains('provident')) {
      return '''
**Provident Fund (PF) in Nepal:**

**Types:**
1. **Citizens Investment Trust (CIT)** - For government employees
2. **Employees Provident Fund (EPF)** - For private sector
3. **Social Security Fund (SSF)** - Mandatory for certain businesses

**Tax Benefits:**
- Contributions are 100% tax-deductible
- No upper limit on deduction
- Recommended: Contribute 10% of your salary

**Contribution Rates:**
- CIT/EPF: 10% employee + 10% employer
- SSF: 11% employee + 20% employer

**Should you contribute more?**
If you're in a higher tax bracket (20-36%), every NPR 100 you contribute to PF saves you NPR 20-36 in taxes!

**Retirement Benefits:**
- Tax-free lump sum on retirement
- Long-term wealth building
- Financial security

Would you like to calculate your optimal PF contribution?
''';
    }

    if (question.contains('married') || question.contains('unmarried')) {
      return '''
**Tax Rates: Married vs Unmarried (FY 2081/82)**

**Unmarried Individual:**
- 0-5L: 1%
- 5-7L: 10%
- 7-10L: 20%
- 10-20L: 30%
- Above 20L: 36%

**Married Individual:**
- 0-6L: 1%
- 6-8L: 10%
- 8-11L: 20%
- 11-21L: 30%
- Above 21L: 36%

**Key Difference:**
Married individuals get NPR 1 lakh higher exemption limit in each bracket.

**Tax Savings Example:**
For NPR 15L income:
- Unmarried tax: ~NPR 3.1L
- Married tax: ~NPR 2.8L
- Difference: ~NPR 30,000 savings!

Note: Both spouses working separately are taxed as unmarried individuals unless they opt for joint assessment.
''';
    }

    if (question.contains('deadline') || question.contains('filing')) {
      return '''
**Nepal Tax Filing Deadlines:**

**Annual Income Tax:**
- Deadline: End of Magh (Mid-January to Mid-February)
- File by: Magh 30 (approximately February 13-14)

**Monthly TDS (Tax Deducted at Source):**
- Deadline: 25th of following month
- Example: January TDS due by February 25

**Quarterly VAT:**
- Deadline: 25th of month following quarter end
- Q1 (Shrawan-Ashwin): Due by Kartik 25
- Q2 (Kartik-Poush): Due by Magh 25
- Q3 (Magh-Jestha): Due by Ashadh 25

**Late Filing Penalties:**
- Fine: NPR 10,000+
- Interest: 15% per annum on unpaid tax

**Pro Tip:** File early to avoid last-minute rush!

Need help with filing requirements?
''';
    }

    if (question.contains('vat')) {
      return '''
**Value Added Tax (VAT) in Nepal:**

**Current Rate:** 13%

**VAT Registration:**
- Mandatory if annual turnover exceeds NPR 50 lakhs
- Voluntary registration available for lower turnover

**How VAT Works:**
- Collect VAT on sales (Output VAT)
- Pay VAT on purchases (Input VAT)
- Remit the difference to IRD

**Example:**
- Sales: NPR 100,000 + VAT 13,000 = Total 113,000
- Purchases: NPR 60,000 + VAT 7,800 = Total 67,800
- VAT Payable: 13,000 - 7,800 = NPR 5,200

**Filing:**
- Quarterly for most businesses
- Monthly for large taxpayers
- Due by 25th of following month/quarter

**Penalties:**
- Late filing: Fine + interest
- Non-registration: Heavy penalties

Need help with VAT calculation or registration?
''';
    }

    // Generic helpful response
    return '''
Thank you for your question about Nepal tax matters!

I'm here to help with:
- Tax calculation and optimization
- Understanding deductions
- Filing requirements
- Nepal Income Tax Act 2058 guidance

Based on your profile:
- Income: NPR ${ref.read(totalIncomeProvider).toStringAsFixed(0)}
- Status: ${ref.read(currentUserProvider)?.isMarried == true ? 'Married' : 'Unmarried'}

Could you please be more specific about what you'd like to know? For example:
- "How can I reduce my tax?"
- "What deductions am I eligible for?"
- "Should I contribute more to PF?"
- "What are the tax rates?"

I'm here to help! 😊

**Disclaimer:** This is educational guidance. Please consult a Chartered Accountant for official tax filing.
''';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.aiAdvisor),
            Text(
              'Ask me anything about Nepal taxes',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _messages.clear();
                _sendWelcomeMessage();
              });
            },
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Questions
          _buildQuickQuestions(),

          // Chat Messages
          Expanded(
            child: _messages.isEmpty
                ? const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'Start a Conversation',
                    message: 'Ask me anything about Nepal tax laws and optimization',
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.smart_toy, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypingDot(0),
                        const SizedBox(width: 4),
                        _buildTypingDot(1),
                        const SizedBox(width: 4),
                        _buildTypingDot(2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input Field
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildQuickQuestions() {
    final questions = [
      'How can I reduce my tax?',
      'What deductions am I missing?',
      'Should I contribute more to PF?',
      'What are the tax rates?',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Questions:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: questions.map((q) {
              return GestureDetector(
                onTap: () => _sendMessage(q),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    q,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: message.isUser ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white70
                          : AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        if (mounted && _isTyping) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask your tax question...',
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}