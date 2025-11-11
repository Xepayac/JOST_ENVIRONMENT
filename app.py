import streamlit as st
import os
import json
from backend.src.jost_engine.main import run_simulation_from_config

def get_profile_files(profile_type):
    """
    Scans the backend/src/jost_engine/data/defaults directory for a specific type of profile 
    and returns a list of filenames (without .json extension).
    """
    # Adjusted path to correctly point to the engine's data directory
    path = os.path.join("backend", "src", "jost_engine", "data", "defaults", profile_type)
    # st.info(f"Checking for {profile_type} in: {path}") # Debugging line
    try:
        if not os.path.exists(path):
            st.error(f"Error: Data path not found for {profile_type}: {path}")
            return []
        files = [f.replace(".json", "") for f in os.listdir(path) if f.endswith(".json")]
        # st.info(f"Found {len(files)} {profile_type} files: {files}") # Debugging line
        return files
    except Exception as e:
        st.error(f"An unexpected error occurred while reading {profile_type} files: {e}")
        return []

st.title("JOST Blackjack Simulation Platform")

st.write("Welcome! This is the starting point for the JOST Streamlit application.")

# --- Simulation Configuration UI ---
st.header("Simulation Configuration")

# Get available profiles
casino_files = get_profile_files("casinos")
player_files = get_profile_files("players")
playing_strategy_files = get_profile_files("playing_strategies")
betting_strategy_files = get_profile_files("betting_strategies")

# UI Widgets
selected_casino = st.selectbox("Select Casino Rules", casino_files, index=0 if casino_files else None)
selected_player = st.selectbox("Select Player Profile", player_files, index=0 if player_files else None)
selected_playing_strategy = st.selectbox("Select Playing Strategy", playing_strategy_files, index=0 if playing_strategy_files else None)
selected_betting_strategy = st.selectbox("Select Betting Strategy", betting_strategy_files, index=0 if betting_strategy_files else None)

num_rounds = st.number_input("Number of Rounds", min_value=1, value=10, step=1)

run_simulation_button = st.button("Run Simulation")

# --- Simulation Logic ---
if run_simulation_button:
    if not all([selected_casino, selected_player, selected_playing_strategy, selected_betting_strategy]):
        st.error("Please select all simulation parameters.")
    else:
        st.write("Running simulation...")
        
        # Construct the config dictionary for the jost_engine
        simulation_config = {
            "casino": selected_casino,
            "num_rounds": num_rounds,
            "players": [
                {
                    "profile": selected_player,
                    "playing_strategy": selected_playing_strategy,
                    "betting_strategy": selected_betting_strategy
                }
            ]
        }

        try:
            # Run the simulation
            results = run_simulation_from_config(simulation_config)
            st.success("Simulation completed!")
            st.session_state["simulation_results"] = results
        except Exception as e:
            st.error(f"An error occurred during simulation: {e}")

# Display results if available (Phase 3, Step 3)
if "simulation_results" in st.session_state:
    st.header("Simulation Results")
    st.json(st.session_state["simulation_results"])
