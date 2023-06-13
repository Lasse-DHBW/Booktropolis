import os
from dotenv import load_dotenv
import psycopg2
import pandas as pd
import streamlit as st

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

st.set_page_config(
    page_title="Booktropolis",
    page_icon=":books:",
    layout="wide",
    initial_sidebar_state="expanded",
)

st.markdown(
    """
    <style>
        body {
            color: #000000;
        }
        @media (prefers-color-scheme: dark) {
            body, .reportview-container {
                color: #ffffff;
            }
        }
    </style>
    """,
    unsafe_allow_html=True,
)

def create_conn():
    conn = None
    try:
        conn = psycopg2.connect(DATABASE_URL)
    except psycopg2.Error as e:
        st.error(f"Error occurred while connecting to database: {e}")
    return conn

def write_dataframe(df, full_width=False, height=None):
    df = df.reset_index(drop=True)
    df_html = df.to_html(index=False)
    if full_width:
        st.write(df_html, unsafe_allow_html=True)
    else:
        st.write(df_html, unsafe_allow_html=True)

def fetch_query(query):
    try:
        with create_conn() as conn:
            df = pd.read_sql_query(query, conn)
    except Exception as e:
        st.error(f"An error occurred: {e}")
        df = pd.DataFrame()
    return df

def execute_query(query):
    conn = create_conn()
    if conn is not None:
        try:
            cur = conn.cursor()
            cur.execute(query)
            conn.commit()
            # Print the notices
            print(conn.notices)
        except Exception as e:
            st.error(f"Error: {e}")
        else:
            st.success("Query executed successfully.")

def create_operation(table_name, table_fields):
    conn = create_conn()
    if conn is not None:
        with st.form(key=f'{table_name}_insert_form'):
            for field in table_fields:
                if st.session_state['SHOW_PREVIEW']:
                    st.session_state[field] = f"{table_fields[field]}"
                else:
                    st.session_state[field] = ""
                st.session_state[field] = st.text_input(field, value=st.session_state[field])
            submit_button = st.form_submit_button(label='Insert')
        if submit_button:
            try:
                # Insert the data
                cur = conn.cursor()
                fields_str = ', '.join(table_fields)
                values_str = ', '.join([f"'{st.session_state[field]}'" for field in table_fields])
                cur.execute(f"""
                    INSERT INTO {table_name} ({fields_str})
                    VALUES ({values_str});
                """)
                conn.commit()
            except Exception as e:
                st.error(f"Error: {e}")
            else:
                st.success("Record inserted successfully.")
                st.experimental_rerun()

def read_operation(table_name):
    query = f"SELECT * FROM {table_name};"
    df = fetch_query(query)
    if df is not None:
        write_dataframe(df, full_width=True)

def update_operation(table_name, table_fields):
    conn = create_conn()
    if conn is not None:
        # Initialize the session state variables for the fields
        for field in table_fields:
            if st.session_state['SHOW_PREVIEW']:
                st.session_state[field] = f"{table_fields[field]}"
            else:
                st.session_state[field] = ""

        with st.form(key=f'{table_name}_update_form'):
            st.write("Primary key for update operation: ", list(table_fields.keys())[0])
            condition_value = st.text_input("Condition value", value="")
            for field in table_fields:
                if field != list(table_fields.keys())[0]: # Skip the primary key field for the update
                    st.session_state[field] = st.text_input(field, value=st.session_state[field])
            submit_button = st.form_submit_button(label='Update')
        if submit_button:
            try:
                # Update the data
                cur = conn.cursor()
                set_values = ', '.join([f"{field} = '{st.session_state[field]}'" for field in table_fields if field != list(table_fields.keys())[0]]) # Skip the primary key field for the update
                cur.execute(f"""
                    UPDATE {table_name}
                    SET {set_values}
                    WHERE {list(table_fields.keys())[0]} = '{condition_value}';
                """)
                conn.commit()
            except Exception as e:
                st.error(f"Error: {e}")
            else:
                st.success("Record updated successfully.")  
                st.experimental_rerun()

def delete_operation(table_name, table_fields):
    conn = create_conn()
    if conn is not None:
        with st.form(key=f'{table_name}_delete_form'):
            condition_field = st.selectbox("Choose field for delete condition", table_fields)
            condition_value = st.text_input("Condition value", value="")
            submit_button = st.form_submit_button(label='Delete')
        if submit_button:
            try:
                cur = conn.cursor()
                cur.execute(f"""
                    DELETE FROM {table_name}
                    WHERE {condition_field} = '{condition_value}';
                """)
                conn.commit()
            except Exception as e:
                st.error(f"Error: {e}")
            else:
                st.success("Record deleted successfully.")
                st.experimental_rerun()
                
def show_home():
    """
    Function to render the home page
    """
    st.title('Welcome to Booktropolis! 📚🏛️🌍')

    st.markdown(
        """
        <style>
            .highlight {
                color: #ffffff /*#f5ab35;*/
            }
        </style>
        """,
        unsafe_allow_html=True,
    )

    st.markdown('## 🎉 Our values are simple.')
    st.markdown("""
    1. **Accessibility:** 💻 Gain access to all your library data anytime, anywhere.
    2. **Variety:** 📚 A vast collection of books spanning across various genres.
    3. **User-friendly:** ✅ An easy-to-navigate platform, ensuring a hassle-free experience.
    """, unsafe_allow_html=True)

    st.markdown('## 🚀 Start exploring now!')
    st.markdown("""
    Choose a table from the menu on the left to begin your journey in Booktropolis.
    """)
    if 'SHOW_PREVIEW' not in st.session_state:
        st.session_state['SHOW_PREVIEW'] = False
    
    st.session_state['SHOW_PREVIEW'] = st.checkbox("Show data type previews", value=st.session_state['SHOW_PREVIEW'])
    st.markdown("***")

    st.markdown('## 🧠 Advanced: Custom SQL Insertion', unsafe_allow_html=True)
    st.markdown('<p class="highlight">Enter any SQL statement and execute it on the database.</p>', unsafe_allow_html=True)
    custom_sql = st.text_input('Write your SQL statement here...', value=(""))
    
    if st.button('Execute SQL'):
        try:
            with create_conn() as conn:
                df = pd.read_sql_query(custom_sql, conn)
            st.success('SQL query executed successfully.')
            st.dataframe(df)
        except Exception as e:
            st.error(f"An error occurred: {e}")
    st.markdown("***")

def main():
    # Define data types for each field in the tables
    field_data_types = {
    "Author": {
        "AuthorID": "integer",
        "FirstName": "string",
        "LastName": "string",
        "Gender": "string",
        "Birthdate": "date",
        "Nationality": "string",
        "Artistname": "string",
    },
    "Publisher": {
        "PublisherID": "integer",
        "Name": "string",
        "Email": "string",
        "Website": "string",
        "AddressID": "integer"
    },
    "Customer": {
        "CustomerID": "integer",
        "FirstName": "string",
        "LastName": "string",
        "Email": "string",
        "Phonenumber": "string",
        "Birthdate": "date",
        "AddressID": "integer"
    },
    "Staffmember": {
        "StaffmemberID": "integer",
        "FirstName": "string",
        "LastName": "string",
        "Salary": "numeric",
        "AvailableVacationDays": "integer",
        "BuildingID": "integer",
        "AddressID": "integer"
    },
    "Book": {
        "BookID": "integer",
        "Title": "string",
        "Genre": "string",
        "ReleaseDate": "date",
        "Keyword": "string",
        "PublisherID": "integer"
    },
    "Copy": {
        "CopyID": "integer",
        "BookID": "integer",
        "CustomerID": "integer",
        "CheckoutDate": "date",
        "DueDate": "date",
        "IsReturned": "boolean",
        "BuildingID": "integer",
        "FloorNumber": "integer",
        "ShelfNumber": "integer"
    },
    "Building": {
        "BuildingID": "integer",
        "FloorNumber": "integer",
        "WheelchairAccessibility": "boolean",
        "AddressID": "integer"
    },
    "Address": {
        "AddressID": "integer",
        "Street": "string",
        "City": "string",
        "PostalCode": "string",
        "State": "string"
    },
    "Write": {
        "AuthorID": "integer",
        "BookID": "integer"
    },
    "Review": {
        "BookID": "integer",
        "CustomerID": "integer",
        "Stars": "integer",
        "Text": "string"
    }
    } 

    st.sidebar.title("Booktropolis")
    st.sidebar.image("logo.jpg", use_column_width=True)
    menu = ["Home", "CustomerCheckoutView", "BookAuthorPublisherMaterializedView", "Author", "Publisher", "Customer", "Staffmember", "Book", "Copy", "Building", "Address", "Write", "Review"]
    choice = st.sidebar.selectbox("Menu", menu)
    if choice == "Home":
        show_home()
    elif choice in ["CustomerCheckoutView", "BookAuthorPublisherMaterializedView"]:
        st.title(f"View: {choice}")
        st.markdown("### Current data")
        read_operation(choice)
    elif choice in ["Write", "Review"]:
        # Get the dictionary for the chosen table
        fields = field_data_types.get(choice, {})

        st.title(f"Table: {choice}")
        st.markdown("### Current data")
        read_operation(choice)
        st.markdown("---")
        
        operations = ["Insert", "Delete"]
        operation = st.selectbox("Choose operation", operations)
        
        if operation == "Insert":
            create_operation(choice, fields)
        elif operation == "Delete":
            delete_operation(choice, fields)
        else:
            read_operation(choice)
    else:
        # Get the dictionary for the chosen table
        fields = field_data_types.get(choice, {})

        st.title(f"Table: {choice}")
        st.markdown("### Current data")
        read_operation(choice)
        st.markdown("---")
        
        operations = ["Insert", "Update", "Delete"]
        operation = st.selectbox("Choose operation", operations)
        
        if operation == "Insert":
            create_operation(choice, fields)
        elif operation == "Update":
            update_operation(choice, fields)
        elif operation == "Delete":
            delete_operation(choice, fields)
        else:
            read_operation(choice)

if __name__ == "__main__":
    main()

