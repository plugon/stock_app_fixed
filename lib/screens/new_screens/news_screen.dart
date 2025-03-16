import 'package:flutter/material.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final List<NewsItem> _newsItems = [
    NewsItem(
      title: "삼성전자, 신형 반도체 생산 라인 확장 계획 발표",
      source: "경제신문",
      date: "2025-03-15",
      imageUrl: "https://via.placeholder.com/150",
      content: "삼성전자가 신형 반도체 생산 라인 확장 계획을 발표했습니다. 이번 투자로 생산량이 30% 증가할 것으로 예상됩니다.",
    ),
    NewsItem(
      title: "애플, 신규 AI 기능 탑재한 아이폰 출시 예정",
      source: "테크뉴스",
      date: "2025-03-14",
      imageUrl: "https://via.placeholder.com/150",
      content: "애플이 다음 달 신규 AI 기능을 탑재한 아이폰을 출시할 예정입니다. 이번 모델은 혁신적인 AI 기술을 포함하고 있습니다.",
    ),
    NewsItem(
      title: "비트코인, 사상 최고가 경신",
      source: "코인데일리",
      date: "2025-03-13",
      imageUrl: "https://via.placeholder.com/150",
      content: "비트코인이 어제 사상 최고가를 경신했습니다. 전문가들은 이번 상승세가 당분간 지속될 것으로 전망합니다.",
    ),
    NewsItem(
      title: "한국은행, 기준금리 동결 결정",
      source: "금융타임즈",
      date: "2025-03-12",
      imageUrl: "https://via.placeholder.com/150",
      content: "한국은행이 이번 달 기준금리를 동결하기로 결정했습니다. 이는 시장 예상과 일치하는 결정입니다.",
    ),
    NewsItem(
      title: "현대차, 전기차 신모델 공개",
      source: "자동차뉴스",
      date: "2025-03-11",
      imageUrl: "https://via.placeholder.com/150",
      content: "현대자동차가 새로운 전기차 모델을 공개했습니다. 이 모델은 한 번 충전으로 600km 주행이 가능합니다.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "📰 주식 뉴스",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "뉴스 검색",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "오늘의 주요 뉴스",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _newsItems.length,
                itemBuilder: (context, index) {
                  return _buildNewsCard(_newsItems[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsItem news) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showNewsDetail(news);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  news.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${news.source} · ${news.date}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      news.content,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewsDetail(NewsItem news) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    news.source,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    news.date,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                news.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  news.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    news.content + "\n\n" + _getDummyContent(),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

  NewsItem({
    required this.title,
    required this.source,
    required this.date,
    required this.imageUrl,
    required this.content,
  });
}
