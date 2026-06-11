import 'package:flutter/material.dart';

class EnglishLearnResource {
  final String id;
  final String title;
  final String description;
  final String category;
  final String url;
  final IconData icon;
  final List<Color> gradient;

  const EnglishLearnResource({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.url,
    required this.icon,
    required this.gradient,
  });
}

const List<EnglishLearnResource> englishLearnResources = [
  EnglishLearnResource(
    id: 'e1',
    title: 'ADA Brushing Guide',
    category: 'Brushing',
    description: 'Proper brushing methods and daily oral care.',
    url: 'https://www.mouthhealthy.org/en/az-topics/b/brushing-your-teeth',
    icon: Icons.clean_hands_rounded,
    gradient: [Color(0xFF0F766E), Color(0xFF14B8A6)],
  ),
  EnglishLearnResource(
    id: 'e2',
    title: 'Flossing Instructions',
    category: 'Brushing',
    description: 'Step-by-step flossing guidance.',
    url: 'https://www.mouthhealthy.org/en/az-topics/f/flossing',
    icon: Icons.front_hand_rounded,
    gradient: [Color(0xFF2563EB), Color(0xFF38BDF8)],
  ),
  EnglishLearnResource(
    id: 'e3',
    title: 'Tooth Decay Prevention',
    category: 'Prevention',
    description: 'How cavities form and how to prevent them.',
    url: 'https://www.nidcr.nih.gov/health-info/tooth-decay/more-info/tooth-decay-process',
    icon: Icons.shield_rounded,
    gradient: [Color(0xFF0F766E), Color(0xFF22C55E)],
  ),
  EnglishLearnResource(
    id: 'e4',
    title: 'Gum Disease Guide',
    category: 'Gum Care',
    description: 'Learn symptoms and prevention of gum disease.',
    url: 'https://www.nidcr.nih.gov/health-info/gum-disease',
    icon: Icons.healing_rounded,
    gradient: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
  ),
  EnglishLearnResource(
    id: 'e5',
    title: 'Kids Oral Care',
    category: 'Kids',
    description: 'Dental care tips for children and parents.',
    url: 'https://kidshealth.org/en/parents/healthy.html',
    icon: Icons.child_care_rounded,
    gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  ),
  EnglishLearnResource(
    id: 'e6',
    title: 'Nutrition and Teeth',
    category: 'Nutrition',
    description: 'Foods that support healthy teeth.',
    url: 'https://www.ada.org/resources/ada-library/oral-health-topics/nutrition-and-oral-health',
    icon: Icons.restaurant_rounded,
    gradient: [Color(0xFF16A34A), Color(0xFF4ADE80)],
  ),
  EnglishLearnResource(
    id: 'e7',
    title: 'Braces Care',
    category: 'Prevention',
    description: 'Brushing and flossing while wearing braces.',
    url: 'https://aaoinfo.org/whats-trending/life-during-treatment/',
    icon: Icons.medical_services_rounded,
    gradient: [Color(0xFF06B6D4), Color(0xFF67E8F9)],
  ),
  EnglishLearnResource(
    id: 'e8',
    title: 'Oral Hygiene Basics',
    category: 'Brushing',
    description: 'Beginner-friendly oral hygiene education.',
    url: 'https://www.nidcr.nih.gov/health-info/oral-hygiene',
    icon: Icons.menu_book_rounded,
    gradient: [Color(0xFF0F766E), Color(0xFF99F6E4)],
  ),
  EnglishLearnResource(
    id: 'e9',
    title: 'Mouth Care Tips',
    category: 'Nutrition',
    description: 'Simple oral health maintenance tips.',
    url: 'https://www.nia.nih.gov/health/teeth-and-mouth/taking-care-your-teeth-and-mouth',
    icon: Icons.health_and_safety_rounded,
    gradient: [Color(0xFF1D4ED8), Color(0xFF60A5FA)],
  ),
  EnglishLearnResource(
    id: 'e10',
    title: 'WHO Oral Health',
    category: 'Prevention',
    description: 'Global oral health awareness and facts.',
    url: 'https://kidshealth.org/en/parents/healthy.html',
    icon: Icons.public_rounded,
    gradient: [Color(0xFF334155), Color(0xFF94A3B8)],
  ),
];