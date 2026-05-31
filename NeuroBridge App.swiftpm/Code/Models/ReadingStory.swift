import Foundation

struct QuizQuestion: Hashable {
    let question: String
    let options: [String]
    let correctIndex: Int
}

struct ReadingStory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let genre: String
    let icon: String
    let text: String
    let questions: [QuizQuestion]
    

    var wordCount: Int {
        text.split(separator: " ").count
    }
}

struct ReadingLibrary {
    static let stories: [ReadingStory] = [
        ReadingStory(
            title: "The Silent Orbit",
            genre: "Sci-Fi",
            icon: "sparkles",
            text: "Commander Ellis stared out the viewport of the Apollo-19 space station. The Earth looked like a fragile blue marble suspended in an infinite sea of black. They had been orbiting for over six months, conducting micro-gravity plant experiments. Yesterday, the main com-link to Houston went dead. Ellis tried recalibrating the transponders, but the silent static remained. He knew they had enough supplies for another year, but the profound silence of space suddenly felt much heavier. He turned to his co-pilot, Maya, who was floating near the hydroponic bays. 'We are truly on our own now,' he whispered, though the hum of the air scrubbers drowned out his voice.",
            questions: [
                QuizQuestion(question: "What is the name of the space station?", options: ["Apollo-11", "Apollo-19", "Voyager-2", "Star-Command"], correctIndex: 1),
                QuizQuestion(question: "How long had they been orbiting?", options: ["Three weeks", "One year", "Six months", "Two days"], correctIndex: 2),
                QuizQuestion(question: "What went dead yesterday?", options: ["The oxygen scrubbers", "The hydroponics", "The main com-link", "The engine core"], correctIndex: 2),
                QuizQuestion(question: "Who is the co-pilot?", options: ["Houston", "Maya", "Ellis", "Sara"], correctIndex: 1),
                QuizQuestion(question: "What kind of experiments were they conducting?", options: ["Micro-gravity plant experiments", "Radiation tests", "Engine efficiency", "Medical trials"], correctIndex: 0)
            ]
        ),
        ReadingStory(
            title: "The Dusty Attic",
            genre: "Mystery",
            icon: "magnifyingglass",
            text: "The wooden stairs groaned loudly as Clara ascended into the darkness. The air in the attic was thick with dust and smelled faintly of lavender and old paper. She clicked on her flashlight, sweeping the narrow beam across stacks of forgotten cardboard boxes. In the far corner, something caught her eye—a small, ornate wooden chest with brass fittings. It wasn't locked. Clara slowly lifted the heavy lid, revealing a velvet-lined interior. Inside sat a pristine, silver pocket watch that was softly ticking. It made no sense. This house had been abandoned for fifty years, yet the watch was perfectly wound.",
            questions: [
                QuizQuestion(question: "What did the attic smell like?", options: ["Mustard and mold", "Lavender and old paper", "Smoke and ash", "Roses and pine"], correctIndex: 1),
                QuizQuestion(question: "What caught Clara's eye in the corner?", options: ["A dusty mirror", "A brass lamp", "An ornate wooden chest", "A pile of gold"], correctIndex: 2),
                QuizQuestion(question: "What was inside the chest?", options: ["A gold necklace", "Old letters", "A silver pocket watch", "A set of keys"], correctIndex: 2),
                QuizQuestion(question: "Why was the discovery strange?", options: ["The house was abandoned for 50 years", "The chest was locked", "The watch was broken", "The watch belonged to Clara"], correctIndex: 0),
                QuizQuestion(question: "What did Clara use to see in the dark?", options: ["A candle", "A flashlight", "A match", "The moonlight"], correctIndex: 1)
            ]
        ),
        ReadingStory(
            title: "Morning Routine",
            genre: "Daily Life",
            icon: "sun.max.fill",
            text: "Every morning, Arthur woke up exactly at 6:00 AM before his alarm rang. He swung his legs over the edge of the bed and slid his feet into his worn, brown leather slippers. The floorboards were always freezing in November. He shuffled into the small kitchen and filled the copper kettle with tap water. While waiting for the water to boil, he retrieved two slices of whole wheat bread and dropped them into the toaster. The rich aroma of dark roast coffee soon filled the room, bringing a small smile to his wrinkled face. He sat by the window, watching the neighborhood slowly wake up.",
            questions: [
                QuizQuestion(question: "What time does Arthur wake up?", options: ["5:30 AM", "6:00 AM", "7:00 AM", "6:30 AM"], correctIndex: 1),
                QuizQuestion(question: "What color are Arthur's slippers?", options: ["Black", "Gray", "Red", "Brown"], correctIndex: 3),
                QuizQuestion(question: "What kind of kettle does he use?", options: ["Steel", "Iron", "Copper", "Glass"], correctIndex: 2),
                QuizQuestion(question: "What kind of bread does he toast?", options: ["Sourdough", "White", "Rye", "Whole wheat"], correctIndex: 3),
                QuizQuestion(question: "Where does he sit after making coffee?", options: ["By the fireplace", "At the dining table", "By the window", "On the porch"], correctIndex: 2)
            ]
        ),
        ReadingStory(
            title: "The Great Coral Reef",
            genre: "Nature",
            icon: "leaf.fill",
            text: "Below the shimmering turquoise surface lies a bustling underwater metropolis. The coral reef is painted in vibrant shades of neon purple, bright orange, and deep green. Vast schools of silver fish move as one synchronized unit, darting nervously away whenever a shadow passes overhead. A sea turtle gently glides past, its flippers moving steadily as it navigates the rocky sea floor. Tiny clownfish weave quickly between the stinging tentacles of sea anemones. Despite its chaotic appearance, everything in the reef works together in a delicate balance, relying on one another for survival and shelter in the vast ocean.",
            questions: [
                QuizQuestion(question: "What colors are the coral reef?", options: ["Gray and white", "Purple, orange, and green", "Only bright blue", "Red and yellow"], correctIndex: 1),
                QuizQuestion(question: "How do the silver fish move?", options: ["Alone", "In chaotic directions", "As one synchronized unit", "Slowly and lazily"], correctIndex: 2),
                QuizQuestion(question: "What animal glides past the reef?", options: ["A dolphin", "A shark", "A sea turtle", "A whale"], correctIndex: 2),
                QuizQuestion(question: "Where do clownfish weave between?", options: ["Seaweed", "Coral branches", "The stinging tentacles of anemones", "Submarine cables"], correctIndex: 2),
                QuizQuestion(question: "How is the reef described?", options: ["A desolate wasteland", "A bustling underwater metropolis", "A quiet desert", "An isolated cave"], correctIndex: 1)
            ]
        ),
        ReadingStory(
            title: "The Dragon's Coin",
            genre: "Fantasy",
            icon: "flame.fill",
            text: "Elara crept silently into the cavern, her boots muffled by the soft layer of ash. In the center of the massive stone chamber lay the ancient dragon, Ignis, fast asleep. His scales were the color of molten lava, and thick smoke drifted lazily from his nostrils with every deep exhalation. Elara wasn't there to slay him; she was there for a single gold coin. The prophecy stated that the coin underneath the dragon's right claw could unlock the gates of the Citadel. She held her breath, reaching out her trembling hand toward the glittering gold. Just as her fingers brushed the cold metal, a massive yellow eye snapped open.",
            questions: [
                QuizQuestion(question: "What is the dragon's name?", options: ["Smaug", "Ignis", "Draco", "Balerion"], correctIndex: 1),
                QuizQuestion(question: "What color were the dragon's scales?", options: ["Pitch black", "Emerald green", "Molten lava", "Ice blue"], correctIndex: 2),
                QuizQuestion(question: "Why was Elara in the cavern?", options: ["To slay the dragon", "To steal a sword", "To find a single gold coin", "To rescue a prisoner"], correctIndex: 2),
                QuizQuestion(question: "Where was the coin located?", options: ["Under the dragon's tail", "Under the right claw", "In the dragon's mouth", "On a stone pedestal"], correctIndex: 1),
                QuizQuestion(question: "What happened when she touched the coin?", options: ["The dragon sneezed", "A massive yellow eye snapped open", "The cave collapsed", "The coin turned to dust"], correctIndex: 1)
            ]
        ),
        ReadingStory(
            title: "The Clockmaker's Secret",
            genre: "Historical",
            icon: "clock.fill",
            text: "In the hazy, cobblestone streets of 18th century London, Thomas was known as the finest clockmaker. His gears were impossibly microscopic, and his clocks never lost a single second. One rainy evening, a tall man in a dark cloak entered the shop carrying a broken pocket watch. The stranger offered Thomas a heavy bag of gold coins to fix it by midnight. When Thomas opened the back casing, he gasped. The internal gears were not made of brass or steel, but of glowing blue crystal. He quickly realized this watch wasn't tracking hours and minutes, but something else entirely. It was tracking the alignment of the stars.",
            questions: [
                QuizQuestion(question: "In what century does the story take place?", options: ["16th century", "18th century", "19th century", "20th century"], correctIndex: 1),
                QuizQuestion(question: "What was Thomas's profession?", options: ["Blacksmith", "Tailor", "Clockmaker", "Baker"], correctIndex: 2),
                QuizQuestion(question: "What did the tall man want fixed by midnight?", options: ["A grandfather clock", "A pocket watch", "A music box", "A compass"], correctIndex: 1),
                QuizQuestion(question: "What were the internal gears made of?", options: ["Brass and steel", "Pure gold", "Glowing blue crystal", "Carved wood"], correctIndex: 2),
                QuizQuestion(question: "What was the watch actually tracking?", options: ["The tides", "The phases of the moon", "The alignment of the stars", "The seasons"], correctIndex: 2)
            ]
        ),
        ReadingStory(
            title: "The First Marathon",
            genre: "Sports",
            icon: "figure.run",
            text: "The sun beat down relentlessly on the asphalt. Maya's legs felt like heavy lead weights, and every breath burned her lungs. She was currently at mile twenty-two of her very first marathon. 'Just four more miles,' she repeated mechanically in her head. The crowds lining the city streets were a blur of colors and cheering voices. A volunteer handed her a small paper cup of water; she took a sip and splashed the rest over her neck. Turning the final corner, she could see the massive blue finish line banner in the distance. A surge of adrenaline pushed through her exhaustion, and she accelerated her pace.",
            questions: [
                QuizQuestion(question: "How did Maya's legs feel?", options: ["Light as feathers", "Like heavy lead weights", "Completely numb", "Strong and fast"], correctIndex: 1),
                QuizQuestion(question: "What mile was she currently at?", options: ["Mile 10", "Mile 26", "Mile 22", "Mile 18"], correctIndex: 2),
                QuizQuestion(question: "What did the volunteer hand her?", options: ["A snack bar", "A wet towel", "A paper cup of water", "A medal"], correctIndex: 2),
                QuizQuestion(question: "What color was the finish line banner?", options: ["Red", "Blue", "Green", "White"], correctIndex: 1),
                QuizQuestion(question: "What helped her accelerate at the end?", options: ["A fast runner", " A surge of adrenaline", "A cold breeze", "Stopping to rest"], correctIndex: 1)
            ]
        ),
        ReadingStory(
            title: "A Chef's Triumph",
            genre: "Culinary",
            icon: "fork.knife",
            text: "The kitchen was a chaotic symphony of clanking pans and shouting line cooks. Chef Marco wiped sweat from his brow as he plated the final dish for the food critic sitting at table seven. It was a pan-seared scallop with a delicate saffron risotto. He carefully placed a sprig of fresh micro-greens on top using a pair of long tweezers. A waiter quickly whisked the plate away. For the next twenty minutes, Marco nervously paced near the ovens. Finally, the waiter returned with an empty plate and a wide grin. The critic had called it the best seafood dish in the entire city.",
            questions: [
                QuizQuestion(question: "What was the kitchen compared to?", options: ["A quiet library", "A chaotic symphony", "A warzone", "A peaceful garden"], correctIndex: 1),
                QuizQuestion(question: "What dish did Chef Marco prepare?", options: ["Steak frites", "Pan-seared scallop with saffron risotto", "Lobster bisque", "Truffle pasta"], correctIndex: 1),
                QuizQuestion(question: "What tool did he use for the micro-greens?", options: ["A fork", "His fingers", "Long tweezers", "A spatula"], correctIndex: 2),
                QuizQuestion(question: "Who was sitting at table seven?", options: ["The mayor", "His mother", "A famous actor", "A food critic"], correctIndex: 3),
                QuizQuestion(question: "What was the critic's verdict?", options: ["It was too salty", "It was the best seafood dish in the city", "It was average", "It was undercooked"], correctIndex: 1)
            ]
        ),
        ReadingStory(
            title: "The Lost Code",
            genre: "Tech",
            icon: "desktopcomputer",
            text: "It was 3:00 AM, and Emily's screen was the only source of light in the dark apartment. She had been hunting for a single software bug for fourteen hours straight. The server deployment was scheduled for the next morning, and if she didn't fix the memory leak, the whole application would crash under heavy traffic. She rubbed her tired eyes and scrolled through thousands of lines of syntax. Suddenly, she stopped. There it was—a rogue missing semicolon hiding on line 4,052. She quickly typed the symbol, compiled the code, and aggressively hit the 'Run' button. The console flashed green. 'Zero Errors found.' She sank back into her chair, exhausted but victorious.",
            questions: [
                QuizQuestion(question: "What time was it in the story?", options: ["12:00 PM", "3:00 AM", "6:00 AM", "9:00 PM"], correctIndex: 1),
                QuizQuestion(question: "What issue was Emily trying to fix?", options: ["A corrupted database", "A memory leak", "A broken styling tag", "A server outage"], correctIndex: 1),
                QuizQuestion(question: "How long had she been looking for the bug?", options: ["Two days", "Fourteen hours", "Twelve hours", "Three weeks"], correctIndex: 1),
                QuizQuestion(question: "What was the actual error?", options: ["A misspelled variable", "A missing semicolon", "A broken bracket", "An infinite loop"], correctIndex: 1),
                QuizQuestion(question: "What color did the console flash?", options: ["Red", "Green", "Blue", "Yellow"], correctIndex: 1)
            ]
        ),
        ReadingStory(
            title: "Autumn Leaves",
            genre: "Daily Life",
            icon: "leaf.arrow.triangle.circlepath",
            text: "The brisk October wind blew fiercely, scattering bright orange and red leaves across the front lawn. Ben pulled his woolen scarf tighter around his neck and grabbed the heavy wooden rake from the garage. It was a Saturday chore he secretly enjoyed. The rhythmic scraping sound of the rake against the grass was almost hypnotic. Within an hour, he had piled up a massive mountain of colorful autumn leaves near the oak tree. Just as he leaned on the rake to admire his hard work, his golden retriever, Max, sprinted out the back door and launched gracefully directly into the center of the pile, scattering the leaves everywhere.",
            questions: [
                QuizQuestion(question: "What month is it?", options: ["September", "November", "October", "December"], correctIndex: 2),
                QuizQuestion(question: "What tool did Ben grab from the garage?", options: ["A shovel", "A leaf blower", "A lawnmower", "A wooden rake"], correctIndex: 3),
                QuizQuestion(question: "Where did he pile the leaves?", options: ["Near the driveway", "By the fence", "Near the oak tree", "On the porch"], correctIndex: 2),
                QuizQuestion(question: "What is his dog's name?", options: ["Buddy", "Max", "Charlie", "Duke"], correctIndex: 1),
                QuizQuestion(question: "What did the dog do?", options: ["Barked at a squirrel", "Ran away", "Jumped into the leaf pile", "Brought a stick"], correctIndex: 2)
            ]
        ),
        ReadingStory(
            title: "The Final Note",
            genre: "Music",
            icon: "guitars.fill",
            text: "The concert hall was completely silent. Three thousand people sat in darkness, holding their breath. Sarah sat at the grand piano on the center stage, a single spotlight illuminating the black and white keys. Her fingers hovered over the keyboard. She was about to play the most difficult movement of the Sonata. She closed her eyes, remembering her grandfather who had taught her the piece when she was just six years old. Taking a deep breath, her hands crashed down on the keys with incredible power and emotion. The beautiful, complex melody soared through the auditorium, leaving the audience entirely mesmerized.",
            questions: [
                QuizQuestion(question: "How many people were in the audience?", options: ["One thousand", "Five hundred", "Three thousand", "Ten thousand"], correctIndex: 2),
                QuizQuestion(question: "What instrument is Sarah playing?", options: ["Violin", "Cello", "Grand piano", "Flute"], correctIndex: 2),
                QuizQuestion(question: "Who taught her the piece?", options: ["Her mother", "Her grandfather", "Her music teacher", "She taught herself"], correctIndex: 1),
                QuizQuestion(question: "How old was she when she learned it?", options: ["Ten", "Six", "Twelve", "Eight"], correctIndex: 1),
                QuizQuestion(question: "What was the audience's reaction?", options: ["They were mesmerized", "They left early", "They started talking", "They booed"], correctIndex: 0)
            ]
        ),
        ReadingStory(
            title: "Desert Mirage",
            genre: "Adventure",
            icon: "sun.dust.fill",
            text: "The endless dunes of yellow sand stretched in every direction, radiating intense heat that made the air wobble and blur. Pilot Jack wiped grit from his goggles. His small bi-plane had crashed due to an engine failure over two days ago. He only had half a canteen of water left. Trudging up the crest of a particularly steep dune, he shaded his eyes to look at the horizon. In the distance, he saw the faint outline of green palm trees and a sparkling blue lake. He blinked hard, worried that his exhausted mind was playing cruel tricks on him. But as he took a step forward, a bird flew up from the trees.",
            questions: [
                QuizQuestion(question: "Why did the plane crash?", options: ["A sandstorm", "Engine failure", "Ran out of fuel", "Hit a bird"], correctIndex: 1),
                QuizQuestion(question: "How long ago did the plane crash?", options: ["One week", "Over two days ago", "A few hours ago", "Yesterday morning"], correctIndex: 1),
                QuizQuestion(question: "How much water did Jack have left?", options: ["None at all", "Two bottles", "Half a canteen", "A full gallon"], correctIndex: 2),
                QuizQuestion(question: "What did he see in the distance?", options: ["A rescue plane", "A ruined city", "Green palm trees and a lake", "A caravan"], correctIndex: 2),
                QuizQuestion(question: "What convinced him it wasn't a trick?", options: ["A bird flew up from the trees", "He heard water splashing", "He saw a fire", "A person waved"], correctIndex: 0)
            ]
        ),
        ReadingStory(
            title: "The Midnight Train",
            genre: "Mystery",
            icon: "tram.fill",
            text: "Rain lashed against the blurry windows of the midnight express train to Paris. Detective Vance sat in the quiet dining car, stirring his black tea. Only three other passengers were awake: an elderly woman knitting, a businessman hurriedly reading documents, and a young man nervously checking his watch. The lights flickered and suddenly plunged the train car into complete darkness for five seconds. When the emergency backup lights flickered on, Vance immediately noticed something wrong. The thick leather briefcase sitting next to the businessman was completely gone.",
            questions: [
                QuizQuestion(question: "Where is the train heading?", options: ["London", "Berlin", "Paris", "Rome"], correctIndex: 2),
                QuizQuestion(question: "What was Detective Vance drinking?", options: ["Coffee", "Black tea", "Water", "Hot chocolate"], correctIndex: 1),
                QuizQuestion(question: "How long did the lights go out?", options: ["One minute", "Ten seconds", "Five seconds", "An hour"], correctIndex: 2),
                QuizQuestion(question: "What was the elderly woman doing?", options: ["Sleeping", "Reading", "Knitting", "Eating"], correctIndex: 2),
                QuizQuestion(question: "What went missing in the dark?", options: ["The detective's tea", "A leather briefcase", "The young man's watch", "A diamond ring"], correctIndex: 1)
            ]
        ),
        ReadingStory(
            title: "Castle in the Clouds",
            genre: "Fantasy",
            icon: "cloud.fill",
            text: "High above the jagged peaks of the Azure Mountains floated a grand castle made of white marble and gold. It was suspended entirely by powerful air magic. The sky-knights rode magnificent giant eagles, patrolling the perimeter and guarding against dragon attacks. Princess Lira stood on the balcony, letting the high-altitude wind whip her braided hair. Today is the day she would take her final trial to become an eagle rider. She looked down at the earth far below, her stomach twisting with a mix of fierce excitement and terrified adrenaline. She gripped her leather harness and whistled loudly for her mount.",
            questions: [
                QuizQuestion(question: "What was the castle made of?", options: ["Stone and iron", "White marble and gold", "Clouds and mist", "Crystal and glass"], correctIndex: 1),
                QuizQuestion(question: "What keeps the castle floating?", options: ["Balloons", "Giant propellers", "Air magic", "Invisible chains"], correctIndex: 2),
                QuizQuestion(question: "What do the sky-knights ride?", options: ["Pegasus", "Dragons", "Flying horses", "Giant eagles"], correctIndex: 3),
                QuizQuestion(question: "What is Princess Lira's final trial?", options: ["Sword fighting", "Becoming an eagle rider", "Casting a spell", "Defeating a dragon"], correctIndex: 1),
                QuizQuestion(question: "How did Lira call her mount?", options: ["She rang a bell", "She shouted its name", "She blew a horn", "She whistled loudly"], correctIndex: 3)
            ]
        ),
        ReadingStory(
            title: "First Day Out",
            genre: "Daily Life",
            icon: "car.fill",
            text: "Seventeen-year-old Mia gripped the steering wheel so tightly her knuckles turned white. It was her very first time driving completely alone since passing her driving test yesterday. The small silver sedan hummed quietly at the red traffic light. She checked her rearview mirror out of sheer nervous habit. When the light finally clicked to green, she gently pressed the gas pedal and pulled into the intersection. She turned the radio on to a low volume, letting the soothing pop music calm her anxious nerves. With every block she passed without a mistake, a growing sense of immense freedom washed over her.",
            questions: [
                QuizQuestion(question: "How old is Mia?", options: ["Fifteen", "Sixteen", "Seventeen", "Eighteen"], correctIndex: 2),
                QuizQuestion(question: "When did she pass her driving test?", options: ["A week ago", "Yesterday", "A month ago", "This morning"], correctIndex: 1),
                QuizQuestion(question: "What color is her car?", options: ["Red", "Silver", "Black", "Blue"], correctIndex: 1),
                QuizQuestion(question: "What did she turn on to calm her nerves?", options: ["The air conditioner", "The wipers", "The radio", "The heater"], correctIndex: 2),
                QuizQuestion(question: "What feeling washed over her as she drove?", options: ["Fear", "Boredom", "Hunger", "A sense of immense freedom"], correctIndex: 3)
            ]
        )
    ]
}
