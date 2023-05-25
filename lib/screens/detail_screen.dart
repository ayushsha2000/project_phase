import 'dart:ui';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movieapp/bloc/get_movie_videos_bloc.dart';
import 'package:movieapp/model/movie.dart';
import 'package:movieapp/model/video.dart';
import 'package:movieapp/model/video_response.dart';
import 'package:movieapp/style/theme.dart' as Style;
import 'package:movieapp/widgets/casts.dart';
import 'package:movieapp/widgets/movie_info.dart';
import 'package:movieapp/widgets/similar_movies.dart';
import 'package:sliver_fab/sliver_fab.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'video_player.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie? movie;
  MovieDetailScreen({@required this.movie});
  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
 

  @override
  void initState() {
    super.initState();
    movieVideosBloc..getMovieVideos(widget.movie!.id);
  }

  @override
  void dispose() {
    super.dispose();
    movieVideosBloc..drainStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      body: Builder(
        builder: (context) {
          return SliverFab(
            floatingPosition: const FloatingPosition(right: 20),
            floatingWidget: StreamBuilder<VideoResponse>(
              stream: movieVideosBloc.subject.stream,
              builder: (context, AsyncSnapshot<VideoResponse> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.error != null &&
                      snapshot.data!.error.isNotEmpty) {
                    return _buildErrorWidget(snapshot.data!.error);
                  }
                  return _buildVideoWidget(snapshot.data);
                } else if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error.toString());
                } else {
                  return _buildLoadingWidget();
                }
              },
            ),
            expandedHeight: 200.0,
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Style.Colors.mainColor,
                expandedHeight: 200.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.movie!.title.length > 40
                          ?  widget.movie!.title.substring(0, 37) + "..."
                          :  widget.movie!.title,
                      style: const TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.normal),
                    ),
                    background: Stack(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "https://image.tmdb.org/t/p/original/" +
                                        widget.movie!.backPoster)),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: [
                                  0.1,
                                  0.9
                                ],
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.black.withOpacity(0.0)
                                ]),
                          ),
                        ),
                      ],
                    )),
              ),
              SliverPadding(
                  padding: const EdgeInsets.all(0.0),
                  sliver: SliverList(
                      delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.movie!.rating.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          RatingBar(
                            itemSize: 10.0,
                            initialRating: widget.movie!.rating / 2,
                            ratingWidget: RatingWidget(
                              empty: const Icon(
                                EvaIcons.star,
                                color: Style.Colors.secondColor,
                              ),
                              full: const Icon(
                                EvaIcons.star,
                                color: Style.Colors.secondColor,
                              ),
                              half: const Icon(
                                EvaIcons.star,
                                color: Style.Colors.secondColor,
                              ),
                            ),
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                            onRatingUpdate: (rating) {
                            },
                          )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 20.0),
                      child: Text(
                        "OVERVIEW",
                        style: TextStyle(
                            color: Style.Colors.titleColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        widget.movie!.overview,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12.0, height: 1.5),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    MovieInfo(
                      id: widget.movie!.id,
                    ),
                    Casts(
                      id: widget.movie!.id,
                    ),
                    SimilarMovies(id: widget.movie!.id)
                  ])))
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [],
    ));
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Error occured: $error"),
      ],
    ));
  }

  Widget _buildVideoWidget(VideoResponse? data) {
    List<Video> videos = data!.videos;
    return FloatingActionButton(
      backgroundColor: Style.Colors.secondColor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              controller: YoutubePlayerController(
                initialVideoId: videos[0].key,
                flags: const YoutubePlayerFlags(
                  autoPlay: true,
                  mute: true,
                ),
              ),
            ),
          ),
        );
      },
      child: const Icon(Icons.play_arrow),
    );
  }
}
