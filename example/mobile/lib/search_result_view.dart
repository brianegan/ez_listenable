import 'package:common/common.dart';
import 'package:flutter/material.dart';

class SearchResultView extends StatelessWidget {
  final List<Repo> repos;

  SearchResultView({
    Key key,
    @required this.repos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: repos.length,
      itemBuilder: (context, index) {
        final repo = repos[index];

        return InkWell(
          onTap: () => showItem(context, repo),
          child: Container(
            alignment: FractionalOffset.center,
            margin: EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Hero(
                    tag: repo.fullName,
                    child: ClipOval(
                      child: Image.network(
                        repo.owner.avatarUrl,
                        width: 56,
                        height: 56,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 6,
                          bottom: 4,
                        ),
                        child: Text(
                          "${repo.fullName}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          "${repo.url}",
                          style: TextStyle(
                            fontFamily: "Hind",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showItem(BuildContext context, Repo repo) {
    Navigator.push(
      context,
      MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            body: GestureDetector(
              key: Key(repo.owner.avatarUrl),
              onTap: () => Navigator.pop(context),
              child: SizedBox.expand(
                child: Hero(
                  tag: repo.fullName,
                  child: Image.network(
                    repo.owner.avatarUrl,
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
