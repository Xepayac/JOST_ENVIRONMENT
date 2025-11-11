
import streamlit as st
import os
import json
import datetime
from backend.src.jost_engine.main import run_simulation_from_config

# --- Constants ---
CONFIGURATIONS_DIR = os.path.join("backend", "src", "jost_engine", "data", "custom", "configurations")
RESULTS_DIR = os.path.join("backend", "src", "jost_engine", "data", "custom", "results")
CUSTOM_DATA_BASE_PATH = os.path.join("backend", "src", "jost_engine", "data", "custom")

# --- Utility Functions ---
def ensure_dir_exists(path):
    if not os.path.exists(path):
        os.makedirs(path)

# --- File and Profile Management ---
def get_profile_files(profile_type, include_custom=False):
    default_path = os.path.join("backend", "src", "jost_engine", "data", "defaults", profile_type)
    files = []
    if os.path.exists(default_path):
        files.extend([f.replace(".json", "") for f in os.listdir(default_path) if f.endswith(".json")])
    
    if include_custom:
        custom_path = os.path.join(CUSTOM_DATA_BASE_PATH, profile_type)
        ensure_dir_exists(custom_path)
        custom_files = [f.replace(".json", "") for f in os.listdir(custom_path) if f.endswith(".json")]
        files.extend([f"[Custom] {f}" for f in custom_files])
    
    return sorted(list(set(files)))

def load_profile_content(profile_type, profile_name):
    base_path = os.path.join("backend", "src", "jost_engine", "data")
    filepath = None
    if profile_name.startswith("[Custom] "):
        filepath = os.path.join(base_path, "custom", profile_type, f"{profile_name.replace('[Custom] ', '')}.json")
    else:
        filepath = os.path.join(base_path, "defaults", profile_type, f"{profile_name}.json")
    try:
        with open(filepath, "r") as f:
            return json.load(f)
    except Exception as e:
        st.error(f"Error loading {profile_name}: {e}")
        return None

def save_profile_file(profile_data, profile_type, profile_name):
    path = os.path.join(CUSTOM_DATA_BASE_PATH, profile_type)
    ensure_dir_exists(path)
    filepath = os.path.join(path, f"{profile_name}.json")
    try:
        with open(filepath, "w") as f:
            json.dump(profile_data, f, indent=4)
        st.success(f"Custom {profile_type.replace('_', ' ').title()} '{profile_name}' saved.")
    except Exception as e:
        st.error(f"Error saving {profile_name}: {e}")

def delete_custom_file(profile_type, filename):
    clean_name = filename.replace("[Custom] ", "").replace(".json", "")
    if profile_type == "results":
        filepath = os.path.join(RESULTS_DIR, filename)
    else:
        filepath = os.path.join(CUSTOM_DATA_BASE_PATH, profile_type, f"{clean_name}.json")

    if os.path.commonpath([os.path.abspath(filepath), os.path.abspath(CUSTOM_DATA_BASE_PATH)]) != os.path.abspath(CUSTOM_DATA_BASE_PATH):
        st.error(f"Deletion outside of the custom data directory is not allowed.")
        return

    try:
        os.remove(filepath)
        st.success(f"Successfully deleted '{filename}'.")
        st.rerun()
    except FileNotFoundError:
        st.error(f"File not found: {filename}.")
    except Exception as e:
        st.error(f"An error occurred while deleting '{filename}': {e}")

# --- Results Management (Restored) ---
def get_saved_results_files():
    ensure_dir_exists(RESULTS_DIR)
    return [f for f in os.listdir(RESULTS_DIR) if f.endswith(".json")]

def load_result_file(filename):
    filepath = os.path.join(RESULTS_DIR, filename)
    try:
        with open(filepath, "r") as f:
            return json.load(f)
    except Exception as e:
        st.error(f"Error loading result file {filename}: {e}")
        return None

# --- UI Functions ---
def display_simulation_results(results_data):
    st.header("Simulation Results")
    for player_id, player_results in results_data.items():
        st.subheader(f"Results for {player_id}")
        col1, col2 = st.columns(2)
        col1.metric("Initial Bankroll", f"${player_results.get('initial_bankroll', 0):,}")
        col2.metric("Final Bankroll", f"${player_results.get('final_bankroll', 0):,}")
        st.metric("Net Gain/Loss", f"${player_results.get('net_gain_loss', 0):,}")
        st.metric("Total Wagered", f"${player_results.get('total_wagered', 0):,}")
        st.metric("Player Edge", f"{player_results.get('player_edge', 0):.4%}")
        if "hand_history" in player_results:
            with st.expander("View Detailed Hand History"):
                st.dataframe(player_results["hand_history"])

def create_management_tab(profile_type_plural, profile_type_singular):
    st.header(f"Create/Edit Custom {profile_type_plural.replace('_', ' ').title()}")
    all_files = get_profile_files(profile_type_plural, include_custom=True)
    selected_to_edit = st.selectbox(f"Load Profile to Edit", ["-- Create New --"] + all_files, key=f"edit_{profile_type_singular}_select")
    
    custom_name = st.text_input(f"New Custom {profile_type_singular.replace('_', ' ').title()} Name", key=f"custom_{profile_type_singular}_name_input")
    
    content_to_edit = "{}"
    if selected_to_edit != "-- Create New --":
        loaded_content = load_profile_content(profile_type_plural, selected_to_edit)
        if loaded_content:
            content_to_edit = json.dumps(loaded_content, indent=4)
            
    edited_content = st.text_area(f"Edit JSON", value=content_to_edit, height=300, key=f"edit_{profile_type_singular}_json")
    
    if st.button(f"Save Custom {profile_type_singular.replace('_', ' ').title()}", key=f"save_{profile_type_singular}_button"):
        final_name = custom_name or (selected_to_edit.replace('[Custom] ', '') if selected_to_edit != "-- Create New --" else "")
        if not final_name:
            st.error("Please enter a name for the new custom profile.")
        else:
            try:
                parsed_json = json.loads(edited_content)
                save_profile_file(parsed_json, profile_type_plural, final_name)
                st.rerun()
            except json.JSONDecodeError:
                st.error("Invalid JSON format.")

    st.divider()
    st.header(f"Delete Custom {profile_type_plural.replace('_', ' ').title()}")
    custom_files = [f for f in get_profile_files(profile_type_plural, include_custom=True) if f.startswith("[Custom]")]
    if not custom_files:
        st.info(f"No custom {profile_type_plural.replace('_', ' ')} to delete.")
    else:
        profile_to_delete = st.selectbox("Select Custom Profile to Delete", custom_files, key=f"delete_{profile_type_singular}_select")
        if st.button("Delete Selected Profile", key=f"delete_{profile_type_singular}_button", use_container_width=True):
            delete_custom_file(profile_type_plural, profile_to_delete)

# --- Main Application --- 
st.title("JOST Blackjack Simulation Platform")

if 'simulation_name' not in st.session_state:
    st.session_state['simulation_name'] = f"Sim_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}"

tabs = st.tabs(["Run Simulation", "View Past Results", "Manage Casinos", "Manage Players", "Manage Playing Strategies", "Manage Betting Strategies"])

with tabs[0]:
    st.header("Simulation Configuration")
    st.text_input("Simulation Name", key='simulation_name')

    casino_files = get_profile_files("casinos", include_custom=True)
    player_files = get_profile_files("players", include_custom=True)
    playing_strategy_files = get_profile_files("playing_strategies", include_custom=True)
    betting_strategy_files = get_profile_files("betting_strategies", include_custom=True)

    selected_casino = st.selectbox("Select Casino Rules", casino_files)
    selected_player = st.selectbox("Select Player Profile", player_files)
    selected_playing_strategy = st.selectbox("Select Playing Strategy", playing_strategy_files)
    selected_betting_strategy = st.selectbox("Select Betting Strategy", betting_strategy_files)
    num_rounds = st.number_input("Number of Rounds", min_value=1, value=10, step=1)
    include_hand_history = st.checkbox("Include detailed hand history")

    if st.button("Run Simulation"):
        sim_name = st.session_state.simulation_name.strip()
        if not sim_name:
            st.error("Simulation name cannot be empty.")
        else:
            simulation_config = {
                "casino": selected_casino.replace("[Custom] ", ""),
                "num_rounds": num_rounds,
                "include_hand_history": include_hand_history,
                "players": [{
                    "profile": selected_player.replace("[Custom] ", ""),
                    "playing_strategy": selected_playing_strategy.replace("[Custom] ", ""),
                    "betting_strategy": selected_betting_strategy.replace("[Custom] ", "")
                }]
            }
            try:
                with st.spinner("Running simulation..."):
                    results = run_simulation_from_config(simulation_config)
                st.session_state["simulation_results"] = results
                
                ensure_dir_exists(RESULTS_DIR)
                timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                result_filename = f"{sim_name}_{timestamp}.json"
                result_filepath = os.path.join(RESULTS_DIR, result_filename)
                with open(result_filepath, "w") as f:
                    json.dump(results, f, indent=4)
                st.success(f"Simulation complete! Results saved to '{result_filename}'")
                display_simulation_results(results)
            except Exception as e:
                st.error(f"An error occurred during simulation: {e}")

with tabs[1]:
    st.header("View & Manage Past Simulation Results")
    saved_results = sorted(get_saved_results_files(), reverse=True)
    if not saved_results:
        st.info("No saved results found.")
    else:
        selected_result_file = st.selectbox("Select a Result to View", saved_results)
        if selected_result_file:
            col1, col2 = st.columns([3, 1])
            with col2:
                if st.button("Delete this result", key=f"delete_result_{selected_result_file}", use_container_width=True):
                    delete_custom_file("results", selected_result_file)
            
            if selected_result_file in get_saved_results_files():
                results_data = load_result_file(selected_result_file)
                if results_data:
                    with col1:
                        st.write(f"**Viewing:** `{selected_result_file}`")
                    display_simulation_results(results_data)

with tabs[2]:
    create_management_tab("casinos", "casino")
with tabs[3]:
    create_management_tab("players", "player")
with tabs[4]:
    create_management_tab("playing_strategies", "playing_strategy")
with tabs[5]:
    create_management_tab("betting_strategies", "betting_strategy")
