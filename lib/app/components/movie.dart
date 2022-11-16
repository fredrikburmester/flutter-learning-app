import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

Future<Movie> getMovie(String id) async {
  try {
    var response = await Dio().get(
        'https://api.themoviedb.org/3/movie/$id?api_key=cc92bf06c1e236de1c75d1e690d97e97');
    // convert to json object
    print(response.data);
    var movie = Movie.fromJson(response.data);
    return movie;
  } catch (e) {
    throw Exception('Failed to load movies');
  }
}

Widget buildText(String e) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Container(
      color: const Color.fromARGB(255, 240, 188, 0),
      child: Text(
        e,
        style: const TextStyle(fontSize: 20),
      ),
    ),
  );
}

class Movie {
  final String title;

  Movie({required this.title});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
    );
  }
}

class MoviePage extends StatelessWidget {
  const MoviePage({
    Key? key,
    required this.id,
  }) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Movie>(
      future: getMovie(id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CupertinoPageScaffold(
            child: CustomScrollView(
              slivers: <Widget>[
                CupertinoSliverNavigationBar(
                  largeTitle: Text(snapshot.data!.title),
                ),
                SliverFillRemaining(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[buildText(snapshot.data!.title)],
                )),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const Center(child: CupertinoActivityIndicator());
      },
    );
  }
}
