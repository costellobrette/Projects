import streamlit as st
 
# Set the title of the web page
st.set_page_config(page_title="Netlfix Analysis", layout="wide")
 
# Define the sidebar navigation
st.sidebar.title("Navigation")
page = st.sidebar.radio("Go to", ["Reports"])
 
# Define content for each tab
 
if page == "Title":
    st.title("Title")
    st.write("")
if page == "Time & Usage":
    st.title("Time & Usage")
    st.write("")
if page == "Shows":
    st.title("Shows")
    st.write("")
if page == "Movies":
    st.title("Movies")
    st.write("")
if page == "Genres":
    st.title("Genres")
    st.write("")
if page == "Categories by Days/Hours":
    st.title("Categories by Days/Hours")
    st.write("")
if page == "Drill Through View Genres":
    st.title("Drill Through View Genres")
    st.write("")
if page == "Summary":
    st.title("Summary")
    st.write("")
    # Embed Power BI report using an iframe
    report_url = " https://app.powerbi.com/reportEmbed?reportId=9955d39a-3ec2-4758-8f1d-37bcf88748ae&autoAuth=true&ctid=c59bd97a-4b1b-4dab-89ac-a0ab6a8e4435"
    st.markdown(f'<iframe title="Netflix BI Presentation" width="1140" height="541.25" src="https://app.powerbi.com/reportEmbed?reportId=9955d39a-3ec2-4758-8f1d-37bcf88748ae&autoAuth=true&ctid=c59bd97a-4b1b-4dab-89ac-a0ab6a8e4435" frameborder="0" allowFullScreen="true"></iframe>',unsafe_allow_html=True)