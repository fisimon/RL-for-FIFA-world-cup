import scrapy
uri = "https://www.fifa.com/worldcup/archive/{}/matches/index.html"
class BlogSpider(scrapy.Spider):
    name = 'blogspider'

    cups = ['southafrica2010',
             'germany2006',
             'koreajapan2002',
             'brazil2014',
             'france1998',
             'usa1994',
             'italy1990',
             'mexico1986',
             'spain1982',
             'argentina1978',
             'germany1974',
             'mexico1970',
             'england1966',
             'chile1962',
             'sweden1958',
             'switzerland1954',
             'brazil1950',
             'france1938',
             'italy1934',
             'uruguay1930']
    start_urls = [uri.format(x) for x in cups]

    def parse(self, response):
        cup = response.css('h1 ::text').extract_first().strip()
        for match in response.css('div.match-list div.col-xs-12'):
            yield {'home': match.css('div.home .t-nText ::text').extract_first(),
                   'away': match.css('div.away .t-nText ::text').extract_first(),
                   'result': match.css('span.s-scoreText ::text').extract_first(),
                   'group': match.css('div.mu-i-group ::text').extract_first(),
                   'date': match.css('div.mu-i-date ::text').extract_first(),
                   'matchnum': match.css('div.mu-i-matchnum ::text').extract_first(),
                   'cup': cup
                   }
