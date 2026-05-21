import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme.dart';

class LearnScreenV2 extends StatefulWidget {
  const LearnScreenV2({super.key});

  @override
  State<LearnScreenV2> createState() => _LearnScreenV2State();
}

class _LearnScreenV2State extends State<LearnScreenV2> {
  final List<Resource> _english = const [
    Resource(
      id: 'e1',
      title: 'ADA Brushing Guide',
      category: 'Brushing',
      description: 'Proper brushing methods and daily oral care.',
      url: 'https://www.mouthhealthy.org/en/az-topics/b/brushing-your-teeth',
    ),
    Resource(
      id: 'e2',
      title: 'Flossing Instructions',
      category: 'Flossing',
      description: 'Step-by-step flossing guidance.',
      url: 'https://www.mouthhealthy.org/en/az-topics/f/flossing',
    ),
    Resource(
      id: 'e3',
      title: 'Tooth Decay Prevention',
      category: 'Prevention',
      description: 'How cavities form and how to prevent them.',
      url: 'https://www.nidcr.nih.gov/health-info/tooth-decay/more-info/tooth-decay-process',
    ),
    Resource(
      id: 'e4',
      title: 'Gum Disease Guide',
      category: 'Gum Care',
      description: 'Learn symptoms and prevention of gum disease.',
      url: 'https://www.nidcr.nih.gov/health-info/gum-disease',
    ),
    Resource(
      id: 'e5',
      title: 'Kids Oral Care',
      category: 'Kids',
      description: 'Dental care tips for children and parents.',
      url: 'https://kidshealth.org/en/parents/healthy.html',
    ),
    Resource(
      id: 'e6',
      title: 'Nutrition and Teeth',
      category: 'Nutrition',
      description: 'Foods that support healthy teeth.',
      url: 'https://www.ada.org/resources/ada-library/oral-health-topics/nutrition-and-oral-health',
    ),
    Resource(
      id: 'e7',
      title: 'Braces Care',
      category: 'Orthodontics',
      description: 'Brushing and flossing while wearing braces.',
      url: 'https://aaoinfo.org/whats-trending/life-during-treatment/',
    ),
    Resource(
      id: 'e8',
      title: 'Oral Hygiene Basics',
      category: 'Basics',
      description: 'Beginner-friendly oral hygiene education.',
      url: 'https://www.nidcr.nih.gov/health-info/oral-hygiene',
    ),
    Resource(
      id: 'e9',
      title: 'Mouth Care Tips',
      category: 'Health Tips',
      description: 'Simple oral health maintenance tips.',
      url: 'https://www.nia.nih.gov/health/teeth-and-mouth/taking-care-your-teeth-and-mouth',
    ),
    Resource(
      id: 'e10',
      title: 'WHO Oral Health',
      category: 'WHO',
      description: 'Global oral health awareness and facts.',
      url: 'https://kidshealth.org/en/parents/healthy.html',
    ),
  ];

  final List<Resource> _tamil = const [
    Resource(
      id: 't1',
      title: 'தமிழ் பல் ஆரோக்கிய கட்டுரைகள்',
      category: 'ஆரோக்கியம்',
      description: 'தமிழில் பல் பராமரிப்பு மற்றும் வாய்நல கட்டுரைகள்.',
      url: 'https://www.ada.org/resources/ada-library/oral-health-topics/nutrition-and-oral-health',
    ),
    Resource(
      id: 't2',
      title: 'விகடன் ஆரோக்கியம்',
      category: 'நலன்',
      description: 'ஆரோக்கியம் மற்றும் பல் விழிப்புணர்வு தொடர்பான தமிழ் கட்டுரைகள்.',
      url: 'https://aaoinfo.org/whats-trending/life-during-treatment/',
    ),
    Resource(
      id: 't3',
      title: 'நியூஸ்18 தமிழ் ஆரோக்கியம்',
      category: 'செய்திகள்',
      description: 'நலன் மற்றும் வாய்நல தொடர்பான தமிழ் செய்திகள்.',
      url: 'https://www.nidcr.nih.gov/health-info/oral-hygiene',
    ),
    Resource(
      id: 't4',
      title: 'மாலைமலர் ஆரோக்கியம்',
      category: 'தடுப்பு',
      description: 'தடுப்பு ஆரோக்கியம் மற்றும் வாய்ப்பராமரிப்பு வழிகாட்டுதல்.',
      url: 'https://www.maalaimalar.com/health',
    ),
    Resource(
      id: 't5',
      title: 'ஒன் எம் ஜி தமிழ் ஆரோக்கியம்',
      category: 'மருத்துவம்',
      description: 'தமிழில் மருத்துவம் மற்றும் பல் கல்வி வளங்கள்.',
      url: 'https://www.1mg.com/ta/',
    ),
    Resource(
      id: 't6',
      title: 'ஒன்லிமைஹெல்த் தமிழ்',
      category: 'வாழ்க்கைமுறை',
      description: 'தமிழில் ஆரோக்கியம் மற்றும் வாய்நல விழிப்புணர்வு.',
      url: 'https://tamil.onlymyhealth.com/',
    ),
    Resource(
      id: 't7',
      title: 'பிபிசி தமிழ் ஆரோக்கியம்',
      category: 'விழிப்புணர்வு',
      description: 'பொது ஆரோக்கிய விழிப்புணர்வு குறித்த தமிழ் கட்டுரைகள்.',
      url: 'https://www.bbc.com/tamil/topics/c340q430m4vt',
    ),
    Resource(
      id: 't8',
      title: 'நலம் தமிழ் ஆரோக்கியம்',
      category: 'நலவாழ்வு',
      description: 'ஆரோக்கியமான வாழ்க்கைமுறை மற்றும் நலவாழ்வு கல்வி.',
      url: 'https://www.nalam360.com/',
    ),
    Resource(
      id: 't9',
      title: 'தினமலர் ஆரோக்கியம்',
      category: 'தினசரி ஆரோக்கியம்',
      description: 'வாய்ப்பராமரிப்பு மற்றும் ஆரோக்கிய பராமரிப்பு வழிகாட்டுதல்.',
      url: 'https://www.dinamalar.com/health/',
    ),
    Resource(
      id: 't10',
      title: 'தமிழ் சமயம் ஆரோக்கியம்',
      category: 'ஆரோக்கியக் கட்டுரைகள்',
      description: 'தமிழில் ஆரோக்கியம் மற்றும் பல் பராமரிப்பு கட்டுரைகள்.',
      url: 'https://tamil.samayam.com/lifestyle/health/articlelist/',
    ),
  ];

  String _query = '';

    bool get _isTamil => Localizations.localeOf(context).languageCode == 'ta';

    List<Resource> get _currentResources => _isTamil ? _tamil : _english;

    String get _pageTitle => _isTamil ? 'கற்றல்' : 'Learn';

    String get _searchHint => _isTamil ? 'தலைப்பு அல்லது வகை மூலம் தேடுக' : 'Search by title or category';

    String get _sectionTitle => _isTamil ? 'தமிழ் கற்றல் வளங்கள்' : 'English Learning Resources';

    String get _openLabel => _isTamil ? 'திறக்க' : 'Open';

    String get _emptyState => _isTamil ? 'தேடலுக்கான முடிவுகள் இல்லை' : 'No resources found';

    List<Resource> get _filteredResources => _currentResources
      .where((r) => r.title.toLowerCase().contains(_query) || r.category.toLowerCase().contains(_query))
      .toList();

  Future<void> _openResource(Resource resource) async {
    final uri = Uri.tryParse(resource.url);
    if (uri == null || !(uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_invalidUrlMessage(resource.url))),
      );
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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

  Widget _buildCard(Resource r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openResource(r),
          child: Container(
            constraints: const BoxConstraints(minHeight: 96),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE6ECEC)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.picture_as_pdf, size: 36, color: Color(0xFF2F80ED)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        r.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.description,
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.category,
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 84),
                    child: ElevatedButton(
                      onPressed: () => _openResource(r),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        _openLabel,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Resource {
  final String id;
  final String title;
  final String category;
  final String description;
  final String url;

  const Resource({required this.id, required this.title, this.category = '', required this.description, required this.url});
}

