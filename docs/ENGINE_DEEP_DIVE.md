# `jost_engine` Deep Dive: The Scientific Core

## 1. The Mission: A High-Fidelity Simulation Library

This document provides a detailed breakdown of the `jost_engine`, the scientific heart of the JOST ecosystem.

**Its Core Purpose:** To be a pure, headless, and scientifically precise Python library for simulating Blackjack. Its results must be verifiable, reproducible, and form the trusted foundation for all strategic analysis performed by our tools. It is a library, not a program; it provides the core simulation logic that higher-level applications (like the Web Service and `user_terminal`) can use.

---

## 2. Core Architecture & Key Classes

The engine is designed as a collection of interacting classes, each modeling a real-world component of a Blackjack game.

*   `main.py`: The primary public entry point. The `run_simulation_from_config` function is the main interface to the library.
*   `game.py`: Defines the `Game` class. This is the central orchestrator that manages the entire simulation flow, including shuffling the deck, dealing cards, prompting players for actions, and tracking rounds.
*   `player.py`: Defines the `Player` class. This object tracks an individual player's state, including their `id`, `bankroll`, current `hand`, and, most importantly, their assigned `playing_strategy` and `betting_strategy`.
*   `dealer.py`: Defines the `Dealer` class, which is a specialized actor with a fixed set of rules (e.g., whether to stand on a soft 17).
*   `deck.py`: Implements the `Deck` class, which manages the shoe, card penetration, and shuffling logic.
*   `playing_strategy.py` & `betting_strategy.py`: These modules define the logic that players use to make decisions. They are designed to be pluggable, allowing for easy extension with new strategies.
*   `config_manager.py`: A utility responsible for loading the JSON-based profile files (casinos, players, etc.) from disk.

---

## 3. The Simulation Lifecycle

When `run_simulation_from_config` is called, the following sequence of events occurs:

1.  **Setup (`game_setup.py`):** The `setup_game_from_config` function is called.
    *   It uses `config_manager` to load the specified JSON profiles for the casino and players.
    *   It instantiates the `Dealer` and `Game` objects based on the casino rules.
    *   For each player configuration, it instantiates a `Player` object and attaches the specified `playing_strategy` and `betting_strategy` objects to it.
2.  **Simulation (`game.py`):** The `game.run_simulation()` method is called.
    *   The `Game` object enters a loop for the specified number of rounds.
    *   In each round, it asks each `Player` for their bet (consulting their `betting_strategy`), deals the cards, and then asks each `Player` for their action (consulting their `playing_strategy`).
    *   It plays out the dealer's hand, settles all bets, and records the outcome.
    *   It checks the deck penetration and reshuffles if necessary.
3.  **Data Export (`statistics_calculator.py`):** Once the loop is complete, the `Game` object compiles the raw data from the simulation.
4.  **Return Value:** A final, structured JSON object containing the complete statistical breakdown of the simulation is returned.

---

## 4. The Configuration (`config`) Object

The engine is controlled entirely by a single Python dictionary, known as the `config` object. This object is the blueprint for the simulation.

**Example Structure:**
```json
{
    "casino": "perfect_h17_casino",
    "num_rounds": 10000,
    "players": [
        {
            "profile": "perfect_player_rich",
            "playing_strategy": "perfect_h17_basic_strategy",
            "betting_strategy": "true_count_betting"
        }
    ]
}
```

*   `"casino"`: (String) The filename (without extension) of a casino profile located in the `data/custom/casinos` or `data/defaults/casinos` directory. This file defines the rules of the game (deck count, dealer behavior, etc.).
*   `"num_rounds"`: (Integer) The total number of hands to simulate.
*   `"players"`: (List of Objects) A list of one or more player configurations.
    *   `"profile"`: (String) The filename of a player profile from the `data` directory. This defines the player's name and starting bankroll.
    *   `"playing_strategy"`: (String) The name of the playing strategy to use. This can be a built-in strategy (like `"basic_strategy"`) or a filename of a custom strategy.
    *   `"betting_strategy"`: (String) The name or filename of the betting strategy to use.

---

## 5. Extending the Engine

The engine is designed to be extensible.

*   **To Add a New Casino:** Create a new JSON file in `data/custom/casinos`. Follow the schema of the existing files.
*   **To Add a New Playing Strategy:**
    1.  Create a new JSON file in `data/custom/playing_strategies` that defines the decision matrix.
    2.  Or, for more complex, stateful strategies, you can implement a new strategy class in Python within the `playing_strategies` module.
*   **To Add a New Betting Strategy:** Implement a new class in the `betting_strategy.py` module, inheriting from the base `BettingStrategy` class and implementing its required methods.

This pluggable architecture allows us to continuously expand the engine's capabilities without altering its core simulation logic, preserving its scientific integrity.
