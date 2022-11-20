# Ordle Helper

A program to help determine possible answers in Wordle, Quordle, Octordle, etc.

## Adding winners to the winner list

Winning words can be added to keep track of which words are the most popular winners.

Example: To add brave, blast, and skirt, run the following:

```shell
WINNING_WORDS="brave blast skirt" ruby run.rb
```

The command with no words added is below:

```shell
WINNING_WORDS="" ruby run.rb
```

## Print former winners

```shell
PRINT_WINNERS="1" ruby run.rb 
```
