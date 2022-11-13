# ruby-Hangman Project
-----------
-----------
Objective:
---------------------------
Continue building on Ruby Programming skills by building Hangman by building on OOP methods and use of file serializations to create many saved version of different game instances for any player. 

Instructions:
---------------------------
The Hangman game randomly selects a word from a dictionary text file filtered between 6 to 12 words in length. As per Hangman traditional rules, one letter must be guessed to try and reveal a letter from the hidden word. The player must reveal the word within 10 attempts. A life is lost for an incorrect guess.

At the start of the game the player is prompted if they would to to load a previous game, start a new game, or delete a saved game. This is part of the player opting to save a game during gameplay. If the user opts to save a game, they can enter a unique filename.

Fundementals Employed:
---------------------------
- Basic Ruby: Methods, Arrays, hashes, methods, Loops, Enumerables, Conditional Logics, Debugging, IRB.

- Best Practises: OOP including classes and modules. Files and sterilization via YAML.     

What I learnt:
---------------------------
- Importance of serialize files to maintain state and permanence for a programme's data. 
- For this project, the "save" progress feature was implemented by serialising and deserialising variables via 'YAML.'
- This includes utilising the File class to read or write to this class to open, delete, edit files.
- I opted to use YAML over JSON as YAML as it is widely used in Ruby on Rails (lightweight and straightforward). 

- I also further reinforced my apprecaition and understanding of OOP practise, i.e. to organise code around objects which aids with maintainability and flexibility. 

