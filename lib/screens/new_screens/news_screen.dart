import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/stock_model.dart';


class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with AutomaticKeepAliveClientMixin {
  final List<NewsItem> _newsItems = [
    NewsItem(
      title: "삼성전자, 신형 반도체 생산 라인 확장 계획 발표",
      source: "경제신문",
      date: "2025-03-15",
      imageUrl: "https://via.placeholder.com/150",
      content: "삼성전자가 신형 반도체 생산 라인 확장 계획을 발표했습니다. 이번 투자로 생산량이 30% 증가할 것으로 예상됩니다.",
      category: "국내",
      isRead: false,
      relatedStocks: ["삼성전자", "SK하이닉스"],
    ),
    NewsItem(
      title: "애플, 신규 AI 기능 탑재한 아이폰 출시 예정",
      source: "테크뉴스",
      date: "2025-03-14",
      imageUrl: "https://via.placeholder.com/150",
      content: "애플이 다음 달 신규 AI 기능을 탑재한 아이폰을 출시할 예정입니다. 이번 모델은 혁신적인 AI 기술을 포함하고 있습니다.",
      category: "해외",
      isRead: false,
      relatedStocks: ["애플", "삼성전자"],
    ),
    NewsItem(
      title: "비트코인, 사상 최고가 경신",
      source: "코인데일리",
      date: "2025-03-13",
      imageUrl: "https://via.placeholder.com/150",
      content: "비트코인이 어제 사상 최고가를 경신했습니다. 전문가들은 이번 상승세가 당분간 지속될 것으로 전망합니다.",
      category: "암호화폐",
      isRead: true,
      relatedStocks: [],
    ),
    NewsItem(
      title: "한국은행, 기준금리 동결 결정",
      source: "금융타임즈",
      date: "2025-03-12",
      imageUrl: "https://via.placeholder.com/150",
      content: "한국은행이 이번 달 기준금리를 동결하기로 결정했습니다. 이는 시장 예상과 일치하는 결정입니다.",
      category: "국내",
      isRead: false,
      relatedStocks: ["KB금융", "신한지주", "하나금융지주"],
    ),
    NewsItem(
      title: "현대차, 전기차 신모델 공개",
      source: "자동차뉴스",
      date: "2025-03-11",
      imageUrl: "https://via.placeholder.com/150",
      content: "현대자동차가 새로운 전기차 모델을 공개했습니다. 이 모델은 한 번 충전으로 600km 주행이 가능합니다.",
      category: "국내",
      isRead: true,
      relatedStocks: ["현대차", "기아", "LG에너지솔루션"],
    ),
    NewsItem(
      title: "테슬라, 자율주행 기술 업데이트 발표",
      source: "테크인사이트",
      date: "2025-03-10",
      imageUrl: "https://via.placeholder.com/150",
      content: "테슬라가 자율주행 기술의 중요한 업데이트를 발표했습니다. 이번 업데이트로 안전성이 크게 향상될 전망입니다.",
      category: "해외",
      isRead: false,
      relatedStocks: ["테슬라", "현대차"],
    ),
    NewsItem(
      title: "NVIDIA, AI 칩 신제품 출시로 주가 급등",
      source: "테크크런치",
      date: "2025-03-09",
      imageUrl: "https://via.placeholder.com/150",
      content: "NVIDIA가 새로운 AI 전용 칩을 출시하며 주가가 10% 이상 급등했습니다. 이 제품은 기존 제품보다 성능이 2배 향상되었습니다.",
      category: "해외",
      isRead: false,
      relatedStocks: ["NVIDIA", "AMD", "인텔"],
    ),
  ];

  // 현재 선택된 카테고리
  String _selectedCategory = "전체";
  final List<String> _categories = ["전체", "국내", "해외", "암호화폐", "산업별"];
  
  // 검색어
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  
  // 관심종목 관련 뉴스 우선 표시 옵션
  bool _showRelatedNewsFirst = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 필터링된 뉴스 아이템 가져오기
  List<NewsItem> get _filteredNewsItems {
    List<NewsItem> filtered = List.from(_newsItems);
    
    // 카테고리 필터링
    if (_selectedCategory != "전체") {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }
    
    // 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) => 
        item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.source.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // 관심종목 관련 뉴스 우선 표시
    if (_showRelatedNewsFirst) {
      // 실제 구현에서는 사용자의 관심종목 목록을 가져와서 비교해야 함
      List<String> userWatchlist = ["삼성전자", "현대차", "NVIDIA"];
      
      filtered.sort((a, b) {
        bool aHasRelated = a.relatedStocks.any((stock) => userWatchlist.contains(stock));
        bool bHasRelated = b.relatedStocks.any((stock) => userWatchlist.contains(stock));
        
        if (aHasRelated && !bHasRelated) return -1;
        if (!aHasRelated && bHasRelated) return 1;
        return 0;
      });
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "뉴스",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // 설정 버튼
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'toggle_related') {
                setState(() {
                  _showRelatedNewsFirst = !_showRelatedNewsFirst;
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_related',
                child: Row(
                  children: [
                    Icon(
                      _showRelatedNewsFirst ? Icons.check_box : Icons.check_box_outline_blank,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text('관심종목 뉴스 우선 표시'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "뉴스 검색",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // 카테고리 필터
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 뉴스 목록
          Expanded(
            child: _filteredNewsItems.isEmpty
                ? _buildEmptyState(context)
                : RefreshIndicator(
                    onRefresh: () async {
                      // 실제 구현에서는 여기서 새로운 뉴스를 가져옴
                      await Future.delayed(const Duration(milliseconds: 800));
                      return Future.value();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredNewsItems.length,
                      itemBuilder: (context, index) {
                        return _buildNewsCard(context, _filteredNewsItems[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // 빈 상태 위젯
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "검색 결과가 없습니다",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "다른 검색어나 카테고리를 선택해보세요",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 뉴스 카드 위젯
  Widget _buildNewsCard(BuildContext context, NewsItem news) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            news.isRead = true;
          });
          _showNewsDetail(context, news);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 정보 (출처, 날짜, 카테고리)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        news.source,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        news.date,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      news.category,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 뉴스 내용
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 뉴스 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      news.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 뉴스 텍스트
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목
                        Text(
                          news.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: news.isRead
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // 내용 요약
                        Text(
                          news.content,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // 관련 종목 태그
              if (news.relatedStocks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: news.relatedStocks.map((stock) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stock,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 뉴스 상세 보기
  void _showNewsDetail(BuildContext context, NewsItem news) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // 드래그 핸들
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // 뉴스 내용
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // 상단 정보 (출처, 날짜, 카테고리)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                news.source,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                news.date,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              news.category,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 제목
                      Text(
                        news.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          news.imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 관련 종목 태그
                      if (news.relatedStocks.isNotEmpty) ...[
                        Text(
                          "관련 종목",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: news.relatedStocks.map((stock) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                stock,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // 내용
                      Text(
                        news.content + "\n\n" + _getDummyContent(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // 공유 버튼
                      ElevatedButton.icon(
                        onPressed: () {
                          // 실제 구현에서는 여기서 공유 기능 구현
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("뉴스 공유 기능이 구현될 예정입니다.")),
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text("뉴스 공유하기"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 더미 뉴스 내용
  String _getDummyContent() {
    return "이번 발표는 시장에 큰 영향을 미칠 것으로 예상됩니다. 전문가들은 이번 결정이 해당 기업의 주가에 긍정적인 영향을 줄 것으로 전망하고 있습니다.\n\n"
        "또한 이번 발표로 인해 관련 산업 전반에 걸쳐 파급 효과가 있을 것으로 예상됩니다. 특히 협력사들의 실적에도 긍정적인 영향을 미칠 것으로 보입니다.\n\n"
        "시장 분석가들은 이번 발표 이후 해당 기업의 주가가 단기적으로 10% 이상 상승할 가능성이 있다고 전망하고 있습니다. 장기적으로는 기업의 성장 전략에 따라 더 큰 상승 가능성도 있습니다.\n\n"
        "투자자들은 이번 소식을 긍정적으로 받아들이고 있으며, 관련 주식에 대한 매수세가 증가할 것으로 예상됩니다.";
  }
}

class NewsItem {
  final String title;
  final String source;
  final String date;
  final String imageUrl;
  final String content;
  final String category;
  bool isRead;
  final List<String> relatedStocks;

  NewsItem({
    required this.title,
    required this.source,
    required this.date,
    required this.imageUrl,
    required this.content,
    required this.category,
    required this.isRead,
    required this.relatedStocks,
  });
}
