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
      }
    }
  }
}

//게임 시작 및 진행상황에 관한 정의
