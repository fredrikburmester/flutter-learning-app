import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/movie.dart';

final helloWorldProvider = Provider((_) => 'Scroll up');
Future<List<Movie>> getMovies() async {
  try {
    var response = await Dio().get(
        'https://api.themoviedb.org/3/trending/movie/week?api_key=cc92bf06c1e236de1c75d1e690d97e97');
    // convert list of movies to List
    var movies = response.data['results']
        .map<Movie>((movie) => Movie.fromJson(movie))
        .toList();

    return movies;
  } catch (e) {
    return [];
  }
}

Widget buildText(Movie movie, BuildContext c) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(movie.title),
        ),
        CupertinoButton.filled(
          onPressed: () {
            Navigator.of(c).push(
              CupertinoPageRoute(
                builder: (context) => MoviePage(id: movie.id),
              ),
            );
          },
          child: const Text('See more'),
        ),
      ],
    ),
  );
}

class Movie {
  final String title;
  final String id;

  Movie({required this.title, required this.id});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      id: json['id'].toString(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePage createState() => _HomePage();
}

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    required this.fieldValue,
  });

  final ValueChanged<String> fieldValue;

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      onChanged: (String value) {
        fieldValue(value);
      },
      onSubmitted: (String value) {
        fieldValue(value);
      },
    );
  }
}

class _HomePage extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  final Future<List<Movie>> movies = getMovies();
  late TextEditingController textController;

  String searchText = '';

  bool matchSearchText(String title) {
    return title.toLowerCase().contains(searchText.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        height: 60,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(CupertinoIcons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(CupertinoIcons.search_circle_fill),
            ),
            label: 'Explore',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            if (index == 0) {
              return CupertinoPageScaffold(
                // child: MoviePage(movies: movies),
                child: FutureBuilder<List<Movie>>(
                  future: movies,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CupertinoPageScaffold(
                        child: CustomScrollView(
                          slivers: <Widget>[
                            const CupertinoSliverNavigationBar(
                              largeTitle: Text('Movies'),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SearchTextField(
                                    fieldValue: (String value) {
                                      setState(() {
                                        searchText = value;
                                      });
                                    },
                                  )),
                            ),
                            SliverToBoxAdapter(
                                child: Padding(
                              padding: const EdgeInsets.only(bottom: 100),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: snapshot.data!
                                      .where((movie) =>
                                          matchSearchText(movie.title))
                                      .map((movie) => buildText(movie, context))
                                      .toList()),
                            )),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return const Center(child: CupertinoActivityIndicator());
                  },
                ),
              );
            } else {
              return CupertinoPageScaffold(
                child: Center(
                  child: Text('Explore'),
                ),
              );
            }
          },
        );
      },
    );
  }
}
