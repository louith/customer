// import 'package:customer/screens/Homescreen/components/ServiceCategories.dart';00
import 'package:flutter/material.dart';

class LocationHome extends StatefulWidget {
  const LocationHome({super.key});

  @override
  State<LocationHome> createState() => _LocationHomeState();
}

class _LocationHomeState extends State<LocationHome> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: MediaQuery.of(context).size.width,
      // height: 160,
      // padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Column(
        children: [
          const Row(children: [
            Icon(Icons.pin_drop),
            SizedBox(
              width: 16,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bajada, Davao City',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  '#789, Venus St., Victoria Heights, Damosa,  Davao',
                  style: TextStyle(fontSize: 10),
                  textAlign: TextAlign.left,
                )
              ],
            ),
          ]),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                height: 40,
                width: 200,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              // IconButton(
              //     onPressed: () {
              //       showSearch(
              //         context: context,
              //         delegate: CustomSearchDelegate(),
              //       );
              //     },
              //     icon: Icon(Icons.search))
            ],
          ),
          // ServiceCategories()
        ],
      ),
    );
  }
}
