import 'package:rpg_game_week2/rpg_game_week2.dart' as rpg_game_week2;
import 'dart:io';
import 'dart:math';

class Character {
  String name;
  int health;
  int attackPower;
  int defensePower;

  Character(this.name, this.health, this.attackPower, this.defensePower);

  void attackMonster(Monster monster) {
    monster.health -= attackPower;
    if (monster.health < 0) monster.health = 0;
    print('$name이(가) ${monster.name}에게 $attackPower의 데미지를 입혔습니다.');
  }

  void defend() {
    int recoverHealth = (defensePower ~/ 2);
    health += recoverHealth;
    print('$name이(가) 방어 태세를 취하여 $recoverHealth 만큼 체력을 얻었었습니다.');
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attackPower, 방어력: $defensePower');
  }
}
// 여기까지 캐릭터 클래스에 대한 정의

class Monster {
  String name;
  int health;
  int attackPower;
  final int defensePower = 0;

  Monster(this.name, this.health, int attackPowerMax, int characterDefensePower)
    : attackPower = max(
        Random().nextInt(attackPowerMax),
        characterDefensePower,
      );

  void attackCharacter(Character character) {
    int damage = max(attackPower - character.defensePower, 0);
    character.health -= damage;
    if (character.health < 0) character.health = 0;
    print('$name이(가) ${character.name}에게 $attackPower의 데미지를 입혔습니다.');
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attackPower');
  }
}
// 여기까지 몬스터 클래스에 대한 정의

class Game {
  late Character character;
  List<Monster> monsterList = [];
  int monstersToDefeat;
  int defeatedMonsters = 0;

  Game(this.monstersToDefeat) {
    loadCharacterStats();
    loadMonsterStats();
  }
  //게임 클래스 정의 및 진행 방식 정의 시작
  void startGame() {
    print('게임을 시작합니다!');
    while (character.health > 0 && defeatedMonsters < monstersToDefeat) {
      Monster monster = getRandomMonster();
      print('새로운 몬스터가 나타났습니다!');
      battle(monster);

      if (character.health <= 0) {
        print('캐릭터가 사망했습니다. 게임을 종료합니다.');
        saveGameResult("패배");
        return;
      }

      if (defeatedMonsters >= monstersToDefeat) {
        print('축하합니다! 모든 몬스터를 물리쳤습니다.');
        saveGameResult("승리");
        return;
      }
      stdout.write('다음 몬스터와 싸우시겠습니까? (y/n): ');
      String? choice = stdin.readLineSync()?.toLowerCase();
      if (choice != 'y') {
        print('게임을 종료합니다.');
        saveGameResult("중도 포기");
        return;
        //'n'을 입력하면 게임이 중도 포기처리되며 저장 후 종료
        //게임 시작 및 진행상황에 관한 정의
      }
    }
  }

  void battle(Monster monster) {
    while (character.health > 0 && monster.health > 0) {
      character.showStatus();
      monster.showStatus();

      stdout.write('행동을 선택하세요 (1: 공격, 2: 방어) :');
      String? choice = stdin.readLineSync();
      if (choice == '1') {
        character.attackMonster(monster);
      } else if (choice == '2') {
        character.defend();
      } else {
        print('잘못된 입력입니다. 다시 입력해주세요.');
        continue;
      } //1선택시 공격, 2선택시 방어, 그 외 입력시 에러 메세지 출력
      if (monster.health > 0) {
        monster.attackCharacter(character);
      } else {
        print('${monster.name}을(를) 물리쳤습니다!');
        monsterList.remove(monster);
        defeatedMonsters++;
      } //몬스터는 살아있는 한 플레이어 공격만, 쓰러지면 리스트에서 제거 및 처지된 몬스터 수 증가
    }
  }

  Monster getRandomMonster() {
    return monsterList[Random().nextInt(monsterList.length)];
  } //랜덤으로 몬스터를 불러옴

  void loadCharacterStats() {
    try {
      final file = File('character.txt'); //캐릭터 정보 불러올 파일
      final contents = file.readAsStringSync();
      final stats = contents.split(',');
      if (stats.length != 3)
        throw FormatException('잘못된 캐릭터 정보입니다.'); //캐릭터 정보가 3개가 아닐 경우 예외처리

      int health = int.parse(stats[0]); //첫번째 자리 값을 체력으로
      int attackPower = int.parse(stats[1]); //두번째 자리 값을 공격력으로
      int defensePower = int.parse(stats[2]); //세번째 자리 값을 방어력으로

      String name = getCharacterName(); //캐릭터 이름을 입력받음
      character = Character(name, health, attackPower, defensePower);
    } catch (e) {
      print('캐릭터 정보를 불러오는 중 오류가 발생했습니다: $e');
      exit(1);
    }
  }
  //캐릭터 정보 불러오기

  void loadMonsterStats() {
    try {
      final file = File('monsters.txt'); //몬스터 정보 불러올 파일
      final lines = file.readAsLinesSync();

      for (var line in lines) {
        final stats = line.split(',');
        if (stats.length != 3)
          throw FormatException('잘못된 몬스터 정보입니다.'); //몬스터 정보가 3개가 아닐 경우 예외처리

        String name = stats[0]; //첫번째 자리 값을 몬스터 이름으로
        int health = int.parse(stats[1]); //두번째 자리 값을 체력으로
        int attackPowerMax = int.parse(stats[2]); //세번째 자리 값을 최대 공격력으로
      }
    } catch (e) {
      print('몬스터 정보를 불러오는 중 오류가 발생했습니다: $e');
      exit(1);
    }
  }
  //몬스터 정보 불러오기

  String getCharacterName() {
    stdout.write('캐릭터의 이름을 입력하세요: ');
    String? name = stdin.readLineSync();
    if (name == null ||
        name.isEmpty ||
        !RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name)) {
      print('잘못된 입력입니다. 한글 또는 영문 대소문자만 입력하세요.');
      return getCharacterName(); // null이 입력될 경우 return이 필요함
    } else {
      return name;
    }
  } //한글 또는 영문 대소문자만 캐릭터 이름으로 입력받기

  //게임 플레이 관련 함수 정의

  void saveGameResult(String result) {
    stdout.write('결과를 저장하시겠습니까? (y/n): ');
    String? choice = stdin.readLineSync()?.toLowerCase();

    if (choice == 'y') {
      try {
        final file = File('result.txt');
        file.writeAsStringSync(
          '캐릭터 이름: ${character.name}\n남은체력: ${character.health}\n게임 결과: $result\n\n',
          mode: FileMode.append,
        );
        print('게임 결과가 저장되었습니다.');
      } catch (e) {
        print('게임 결과를 저장하는 중 오류가 발생했습니다: $e');
      }
    }
  }
} //게임 결과 저장하기

void main() {
  Game game = Game(2);
  game.startGame();
}
//게임 시작