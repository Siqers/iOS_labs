struct FavoriteItem {
    let title: String
    let subtitle: String
    let imageName: String
    let rating: Int
    let description: String
}

enum TrailLibrary {
    static let items: [FavoriteItem] = [
        .init(title: "Ala-Archa Gorge", subtitle: "Kyrgyzstan", imageName: "Trail01", rating: 5,
              description: "The trail follows the river into the gorge. Spruce trees shade the early stretch. The peaks come into view as the valley opens."),
        .init(title: "Kolsai Lakes", subtitle: "Kazakhstan", imageName: "Trail02", rating: 5,
              description: "The lower lake is framed by forest. The route to the middle lake climbs through meadows and over roots. The shore is a good place to stop before turning back."),
        .init(title: "Charyn Canyon", subtitle: "Kazakhstan", imageName: "Trail03", rating: 4,
              description: "The path descends between bands of red rock. In the Valley of Castles the walls rise on both sides. There is little shade on the way to the river."),
        .init(title: "Big Almaty Lake", subtitle: "Kazakhstan", imageName: "Trail04", rating: 4,
              description: "The reservoir sits in a basin above Almaty. Its color changes with the light and sediment. The road offers several views of the surrounding slopes."),
        .init(title: "Kaindy Lake", subtitle: "Kazakhstan", imageName: "Trail05", rating: 5,
              description: "Bare spruce trunks rise above the water. They remained after a landslide flooded the valley. A short approach through the forest leads to the shore."),
        .init(title: "Song-Kul", subtitle: "Kyrgyzstan", imageName: "Trail06", rating: 4,
              description: "The lake lies on a broad plateau. In summer, horses graze among the yurts. The open shore offers long views across the water."),
        .init(title: "Jeti-Oguz", subtitle: "Kyrgyzstan", imageName: "Trail07", rating: 4,
              description: "A group of red cliffs marks the entrance to the valley. The rock contrasts with the grass on the lower slopes. A track follows the valley beyond the formations."),
        .init(title: "Skazka Canyon", subtitle: "Kyrgyzstan", imageName: "Trail08", rating: 4,
              description: "Eroded clay forms narrow ridges and little gullies. The colors range from yellow to deep red. A higher viewpoint looks back toward Issyk-Kul."),
        .init(title: "Iskanderkul", subtitle: "Tajikistan", imageName: "Trail09", rating: 5,
              description: "Steep mountains ring this lake in the Fann range. A path from the outlet leads toward a waterfall. The lake is calmest in the early morning."),
        .init(title: "Seven Lakes of the Fann Mountains", subtitle: "Tajikistan", imageName: "Trail10", rating: 5,
              description: "The lakes follow one another up the valley. Each basin has a different color and shape. The climb between villages gives a clear sense of their changing elevation."),
        .init(title: "Karakul Lake", subtitle: "Tajikistan", imageName: "Trail11", rating: 4,
              description: "The lake occupies a wide basin in the Pamirs. The landscape is open and nearly treeless. On a clear day snowy ridges stand out across the water."),
        .init(title: "Wakhan Valley", subtitle: "Tajikistan", imageName: "Trail12", rating: 4,
              description: "The valley stretches along the Panj River. Terraced fields sit below steep slopes. Ruins on the hillsides look across toward the Hindu Kush."),
        .init(title: "Aydarkul", subtitle: "Uzbekistan", imageName: "Trail13", rating: 3,
              description: "The lake interrupts the dry landscape near the Kyzylkum. The shore is low and wide. Reeds and water birds gather in sheltered patches."),
        .init(title: "Chimgan", subtitle: "Uzbekistan", imageName: "Trail14", rating: 4,
              description: "The lower routes cross grassy slopes. Shady gullies break up the climb. As the ridge approaches, the view extends over the western Tian Shan."),
        .init(title: "Charvak Reservoir", subtitle: "Uzbekistan", imageName: "Trail15", rating: 4,
              description: "Several valleys meet at the blue reservoir. The shoreline curves around small coves. The surrounding hills make good viewpoints above the water."),
        .init(title: "Nuratau Mountains", subtitle: "Uzbekistan", imageName: "Trail16", rating: 4,
              description: "The paths pass orchards and stone walls. Small villages sit beside streams at the foot of the hills. Open ridges are visible above the cultivated valley."),
        .init(title: "Yangykala Canyon", subtitle: "Turkmenistan", imageName: "Trail17", rating: 5,
              description: "Bands of pale and red sediment color the cliffs. The rim overlooks a maze of eroded slopes. Long shadows make the layers easier to distinguish."),
        .init(title: "Koytendag Mountains", subtitle: "Turkmenistan", imageName: "Trail18", rating: 4,
              description: "Limestone slopes rise near the eastern border. Gorges cut through the dry hills. The terrain changes quickly between shaded valleys and exposed rock."),
        .init(title: "Altyn-Emel Singing Dune", subtitle: "Kazakhstan", imageName: "Trail19", rating: 5,
              description: "The dune stands by itself above a stony plain. Its crest gives a view toward the Ili River. Dry sand can make a low sound as it slides down the slope."),
        .init(title: "Burabay National Park", subtitle: "Kazakhstan", imageName: "Trail20", rating: 4,
              description: "Pine forest surrounds a chain of lakes. Granite outcrops rise above the trees. Paths along the shoreline connect several viewpoints.")
    ]
}
