import 'dart:math';

/// Offline party-game prompt packs for Kulit Barkada.
class GameContent {
  static final _random = Random();

  static const truths = [
    'Who in this barkada do you trust the most, and why?',
    'What is your most embarrassing moment with this group?',
    'Who would you call first if you got lost?',
    'What is a secret skill nobody here knows you have?',
    'Who here has the best laugh?',
    'What outing do you still regret missing?',
    'Who is most likely to get lost on a trip?',
    'What food do you pretend to like when the group orders it?',
    'Who here would survive a zombie apocalypse?',
    'What is the pettiest reason you got mad at a friend?',
    'Who is the group’s unofficial leader?',
    'What is your go-to karaoke song?',
    'Who here spends the most on snacks?',
    'What is one thing you want this barkada to do this year?',
    'Who would you want as your travel buddy?',
    'What is the funniest nickname someone gave you?',
    'Who is most likely to forget their wallet?',
    'What is a crush story you never told this group?',
    'Who here is the best storyteller?',
    'What is your weirdest habit during hangouts?',
  ];

  static const dares = [
    'Do your best impression of someone in this barkada.',
    'Sing 15 seconds of a random song chosen by the group.',
    'Speak in a cartoon voice for the next 2 rounds.',
    'Let the group pick your next selfie pose.',
    'Send a funny voice note to someone (or pretend to).',
    'Dance for 20 seconds with no music.',
    'Tell a joke — if nobody laughs, do 5 jumping jacks.',
    'Wear your bag/jacket backwards until the next turn.',
    'Talk only in questions for one full minute.',
    'Give a dramatic Oscar speech about this barkada.',
    'Balance something on your head for 20 seconds.',
    'Make up a 10-second commercial for your favorite food.',
    'Let someone redo your hairstyle for this round.',
    'Walk across the room like a runway model.',
    'Say the alphabet backwards as far as you can.',
    'Do a handshake with the person on your left — invent a new one.',
    'Whisper a compliment to every person here.',
    'Hold a serious face while the group tries to make you laugh for 20 seconds.',
    'Act out your morning routine in 15 seconds.',
    'Pick someone and roast them gently for 10 seconds.',
  ];

  static const spyLocations = [
    'Beach resort',
    'Mall food court',
    'Karaoke room',
    'Bus terminal',
    'Coffee shop',
    'Basketball court',
    'School campus',
    'Night market',
    'Hotel lobby',
    'Cinema lobby',
    'Barbershop',
    'Internet cafe',
    'Picnic park',
    'Ferry boat',
    'Birthday party',
  ];

  static String randomTruth() => truths[_random.nextInt(truths.length)];

  static String randomDare() => dares[_random.nextInt(dares.length)];

  static String randomLocation() => spyLocations[_random.nextInt(spyLocations.length)];
}
