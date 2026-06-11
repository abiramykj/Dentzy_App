import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/learning_resource.dart';
import '../services/learning_content_api_service.dart';
import '../services/tracker_service.dart';
import '../utils/theme.dart';

class LearnScreenV2 extends StatefulWidget {
  const LearnScreenV2({super.key});

  @override
  State<LearnScreenV2> createState() => _LearnScreenV2State();
}

class _LearnScreenV2State extends State<LearnScreenV2> {
  static const List<LearningResource> _fallbackEnglishResources = [
    LearningResource(
      id: 'e1',
      title: 'Brushing Your Teeth',
      category: 'Brushing',
      description: 'ADA brushing steps for cleaning all tooth surfaces and protecting gums.',
      url: 'https://www.mouthhealthy.org/en/az-topics/b/brushing-your-teeth',
    ),
    LearningResource(
      id: 'e2',
      title: 'Flossing',
      category: 'Flossing',
      description: 'Daily flossing tips and tools for cleaning between teeth.',
      url: 'https://www.mouthhealthy.org/en/az-topics/f/flossing',
    ),
    LearningResource(
      id: 'e3',
      title: 'Tooth Decay Process',
      category: 'Cavities',
      description: 'How cavities form and how fluoride can help reverse early decay.',
      url: 'https://www.nidcr.nih.gov/health-info/tooth-decay/more-info/tooth-decay-process',
    ),
    LearningResource(
      id: 'e4',
      title: 'Periodontal Gum Disease',
      category: 'Gum Care',
      description: 'Causes, symptoms, and prevention of gum disease.',
      url: 'https://www.nidcr.nih.gov/health-info/gum-disease',
    ),
    LearningResource(
      id: 'e5',
      title: 'Keeping Kids Teeth Healthy',
      category: 'Kids',
      description: 'Brushing, flossing, fluoride, and dentist visits for children.',
      url: 'https://kidshealth.org/en/parents/healthy.html',
    ),
    LearningResource(
      id: 'e6',
      title: 'Nutrition and Oral Health',
      category: 'Nutrition',
      description: 'How sugar, snacks, and drinks affect oral health.',
      url: 'https://www.ada.org/resources/ada-library/oral-health-topics/nutrition-and-oral-health',
    ),
    LearningResource(
      id: 'e7',
      title: 'Life During Treatment',
      category: 'Orthodontics',
      description: 'Simple care tips for teeth and braces during treatment.',
      url: 'https://aaoinfo.org/whats-trending/life-during-treatment/',
    ),
    LearningResource(
      id: 'e8',
      title: 'Oral Hygiene',
      category: 'Hygiene',
      description: 'Brushing, flossing, and daily habits for healthy teeth and gums.',
      url: 'https://www.nidcr.nih.gov/health-info/oral-hygiene',
    ),
    LearningResource(
      id: 'e9',
      title: 'Taking Care of Teeth and Mouth',
      category: 'Older Adults',
      description: 'Oral care tips for teeth, gums, dry mouth, and dentures.',
      url: 'https://www.nia.nih.gov/health/teeth-and-mouth/taking-care-your-teeth-and-mouth',
    ),
    LearningResource(
      id: 'e10',
      title: 'WHO Oral Health Facts',
      category: 'Global Health',
      description: 'WHO facts on oral diseases, prevention, and global oral health.',
      url: 'https://www.who.int/news-room/fact-sheets/detail/oral-health',
    ),
  ];

  static const List<LearningResource> _fallbackTamilResources = [
    LearningResource(
      id: 't1',
      title: 'பல் துலக்கும் வழிமுறை',
      category: 'தினசரி பராமரிப்பு',
      description: 'பற்களின் அனைத்து பகுதிகளையும் சுத்தம் செய்யும் ADA வழிமுறை.',
      url: 'https://translate.google.com/translate?hl=ta&sl=en&tl=ta&u=https://www.mouthhealthy.org/en/az-topics/b/brushing-your-teeth',
    ),
    LearningResource(
      id: 't2',
      title: 'Flossing',
      category: 'பல் இடை சுத்தம்',
      description: 'பற்களுக்கு நடுவில் சுத்தம் செய்யும் தினசரி floss குறிப்புகள்.',
      url: 'https://translate.google.com/translate?hl=ta&sl=en&tl=ta&u=https://www.mouthhealthy.org/en/az-topics/f/flossing',
    ),
    LearningResource(
      id: 't3',
      title: 'பல் சொத்தை செயல்முறை',
      category: 'சொத்தை',
      description: 'சொத்தை எப்படி உருவாகிறது, fluoride எப்படி உதவுகிறது.',
      url: 'https://translate.google.com/translate?hl=ta&sl=en&tl=ta&u=https://www.nidcr.nih.gov/health-info/tooth-decay/more-info/tooth-decay-process',
    ),
    LearningResource(
      id: 't4',
      title: 'ஈறு நோய்',
      category: 'ஈறு பராமரிப்பு',
      description: 'ஈறு நோயின் காரணங்கள், அறிகுறிகள், தடுப்பு.',
      url: 'https://translate.google.com/translate?hl=ta&sl=en&tl=ta&u=https://www.nidcr.nih.gov/health-info/gum-disease',
    ),
    LearningResource(
      id: 't5',
      title: 'குழந்தைகளின் பல் ஆரோக்கியம்',
      category: 'குழந்தைகள்',
      description: 'துலக்குதல், flossing, fluoride, மற்றும் dentist visits.',
      url: 'https://translate.google.com/translate?hl=ta&sl=en&tl=ta&u=https://kidshealth.org/en/parents/healthy.html',
    ),
    LearningResource(
      id: 't6',
      title: 'உணவு மற்றும் வாய்நலம்',
      category: 'உணவுமுறை',
      description: 'சர்க்கரை, snacks, drinks ஆகியவை வாய்நலத்தை எப்படி பாதிக்கின்றன.',
      url: 'https://translate.google.com/translate?hl=ta&sl=en&tl=ta&u=https://www.ada.org/resources/ada-library/oral-health-topics/nutrition-and-oral-health',
    ),
    LearningResource(
      id: 't7',
      title: 'சிகிச்சை கால பராமரிப்பு',
      category: 'பிரேஸ்கள்',
      description: 'பல் சிகிச்சை காலத்தில் teeth மற்றும் braces பராமரிப்பு.',
      url: 'https://translate.google.com/translate?hl=ta&sl=en&tl=ta&u=https://aaoinfo.org/whats-trending/life-during-treatment/',
    ),
    LearningResource(
      id: 't8',
      title: 'வாய்ச் சுகாதாரம்',
      category: 'வாய்ச் சுகாதாரம்',
      description: 'தினசரி துலக்குதல், flossing, மற்றும் நல்ல பழக்கங்கள்.',
      url: 'https://translate.google.com/translate?hl=ta&sl=en&tl=ta&u=https://www.nidcr.nih.gov/health-info/oral-hygiene',
    ),
    LearningResource(
      id: 't9',
      title: 'பற்கள் மற்றும் வாய் பராமரிப்பு',
      category: 'முதியோர்',
      description: 'Dry mouth, dentures, gum care ஆகியவற்றுக்கான குறிப்புகள்.',
      url: 'https://translate.google.com/translate?hl=ta&sl=en&tl=ta&u=https://www.nia.nih.gov/health/teeth-and-mouth/taking-care-your-teeth-and-mouth',
    ),
    LearningResource(
      id: 't10',
      title: 'WHO வாய்நல உண்மைகள்',
      category: 'உலகளாவிய உண்மைத் தகவல்',
      description: 'வாய்நோய்கள், தடுப்பு, மற்றும் உலகளாவிய வாய்நலம் பற்றிய தகவல்கள்.',
      url: 'https://translate.google.com/translate?hl=ta&sl=en&tl=ta&u=https://www.who.int/news-room/fact-sheets/detail/oral-health',
    ),
  ];

  List<LearningResource> _englishResources = _fallbackEnglishResources;
  List<LearningResource> _tamilResources = _fallbackTamilResources;

  String _query = '';
  String? _loadedLanguageCode;

  bool get _isTamil => Localizations.localeOf(context).languageCode == 'ta';

  List<LearningResource> get _currentResources => _isTamil ? _tamilResources : _englishResources;

  String get _pageTitle => _isTamil ? 'கற்றல்' : 'Learn';

  String get _searchHint => _isTamil ? 'தலைப்பு அல்லது வகை மூலம் தேடுக' : 'Search by title or category';

  String get _sectionTitle => _isTamil ? 'தமிழ் கற்றல் வளங்கள்' : 'English Learning Resources';

  String get _openLabel => _isTamil ? 'திறக்க' : 'Open';

  String get _emptyState => _isTamil ? 'தேடலுக்கான முடிவுகள் இல்லை' : 'No resources found';

  List<LearningResource> get _filteredResources => _currentResources
      .where((r) => r.title.toLowerCase().contains(_query) || r.category.toLowerCase().contains(_query))
      .toList();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = _languageCodeFromContext(context);
    if (_loadedLanguageCode != languageCode) {
      _loadedLanguageCode = languageCode;
      unawaited(_loadContentForLanguage(languageCode));
    }
  }

  String _languageCodeFromContext(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ta' ? 'ta' : 'en';
  }

  Future<void> _loadContentForLanguage(String languageCode) async {
    try {
      final apiItems = await LearningContentApiService.instance.fetchArticles(language: languageCode);
      if (!mounted) {
        return;
      }

      final items = apiItems.map((item) => LearningResource.fromApi(item)).toList();
      setState(() {
        if (languageCode == 'ta') {
          _tamilResources = items;
        } else {
          _englishResources = items;
        }
      });
    } catch (error) {
      debugPrint('[LearnScreenV2] API failed, using fallback: $error');
      if (!mounted) {
        return;
      }

      final fallbackItems = languageCode == 'ta' ? _fallbackTamilResources : _fallbackEnglishResources;
      setState(() {
        if (languageCode == 'ta') {
          _tamilResources = fallbackItems;
        } else {
          _englishResources = fallbackItems;
        }
      });
    }
  }

  Future<void> _openResource(LearningResource resource) async {
    final uri = Uri.tryParse(resource.url);
    if (uri == null || !(uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_invalidUrlMessage(resource.url))),
      );
      return;
    }

    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) {
        unawaited(TrackerService.instance.markArticleCompleted(resource.id));
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_unableToOpen)),
      );
    }
  }

  String get _unableToOpen => _isTamil ? 'வளத்தை திறக்க இயலவில்லை' : 'Unable to open resource';

  String _invalidUrlMessage(String url) => _isTamil ? 'தவறான URL: $url' : 'Invalid URL: $url';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        title: Text(_pageTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                key: const Key('learn_search'),
                decoration: InputDecoration(
                  hintText: _searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _sectionTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  if (_filteredResources.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        _emptyState,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    )
                  else
                    ..._filteredResources.map((r) => _buildCard(r)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(LearningResource r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openResource(r),
          child: Container(
            constraints: const BoxConstraints(minHeight: 116),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE6ECEC)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 34, color: Color(0xFF2F80ED)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            r.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            r.description,
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FA),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          r.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _openResource(r),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(_openLabel, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}