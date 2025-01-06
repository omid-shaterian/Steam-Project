![Steam Logo](https://images.app.goo.gl/cZdJWByoSCuq9YLH6)
# Steam games project
This data analysis project involved working with a dataset of over 85,000 game titles published on the Steam platform. The project began with exploratory data analysis (EDA) using PostgreSQL, followed by the creation of an interactive dashboard using Power BI to visualize and interpret the insights effectively.

## project stages

 - finding and downloading the dataset
 - data cleaning and preprocessing
	 - removing unnecessary columns
	 - Estimated owners column
 - Exploratory Data Analysis in postgresql
 - Unwraping the comma separated columns
 - visualization

## finding and downloading the dataset

The first step of my project involved searching for a video game-related dataset. I wanted to work on a topic I was passionate about, steering away from generic and commonly used datasets like Titanic or COVID-19. Finding the right dataset took some time, as I prioritized both recent updates and the inclusion of valuable and relevant information. Although my search for a dataset related to the PlayStation Network was unsuccessful, I ultimately discovered a suitable dataset for the Steam platform, which is currently the largest PC gaming platform.


you can find the dataset here: [Steam Games Dataset](https://huggingface.co/datasets/FronkonGames/steam-games-dataset)

## data cleaning and preprocessing

### removing unnessecary columns
The dataset comprises of on table, with an `appid` column as its primary key. 

Although the data was relatively clean, there were several columns containing URLs for support pages, game websites and also game header pictures. Since I did not plan to use this data for machine learning tasks like computer vision, these columns were unnecessary. To streamline the dataset and save space, I removed these irrelevant columns to keep the tables concise. 
### Estimated owners

The `Estimated Owner` column originally displayed a range between two numbers, separated by a dash ('-'). To simplify data analysis, I replaced this column with the average of the minimum and maximum values, renaming it to `Estimated Sales` to streamline the analysis process.

## Exploratory Data Analysis in PostgreSQL
Performing exploratory data analysis (EDA) on the Steam Game Dataset is a great step to uncover insights. During my exploratory data analysis (EDA), I focused on extracting the most significant insights from the dataset. To achieve this, I ensured that the questions addressed a broad range of topics, including market trends, performance metrics, and competitive analysis. 
These are the business questions that the analysis tried to answer.

----------

### **General Market Insights**

1.  **What are the most popular genres among Steam users?**
    
 
2.  **Which price ranges correlate with higher user scores?**
    

3.  **What is the distribution of release dates across years?**
    

4.  **How does the "Estimated Owners" metric vary across genres or price ranges?**
    


----------

### **Game Performance**

5.  **Which games have the highest average playtime?**
    

6.  **What factors influence Metacritic scores?**
    

7.  **Do games with multiple supported languages perform better in terms of user scores or ownership?**
  
8.  **What is the distribution of positive versus negative reviews?**
    


----------

### **Revenue and Monetization**

9.  **Which pricing strategies seem to work best for developers?**
    

10.  **How does the presence of DLCs correlate with game sales or user scores?**
    

11.  **What is the relationship between sales and platform availability (Windows, Mac, Linux)?**
    
    

----------

### **Temporal Analysis**

12.  **Are certain months or seasons more favorable for game releases?**
    
 
13.  **How have user preferences (genres, playtime) evolved over the years?**
    
  

----------

### **Competitor Analysis**

14.  **Which game developers or publishers have the highest-rated games?**
    
   
15.  **Which game features (genres, supported languages, etc.) are common among top-rated games?**
    
 

----------

### **Player Demographics and Preferences**

16.  **Do games with lower age requirements appeal to a broader audience?**
    

17.  **Which regions (based on supported languages) seem to dominate the gaming space?**
    
  

----------

### **Engagement Metrics**

18.  **How does average playtime correlate with user scores or ownership?**
    

19.  **Are higher-rated games always the ones with higher playtime or ownership?**
    
   

----------

## Unwrapping the  comma separated columns
The dataset contained several columns with comma-separated values, such as Genre, Tags, and Supported Languages. In their original state, these columns were difficult to use effectively for analysis and visualization, as the values could not be assigned individually to each game title. To address this, I unwrapped the data using functions like `UNNEST` and `STRING_TO_ARRAY`.

However, the large number of unique genres, tags, and languages posed a challenge. To manage this complexity and prevent an overwhelming number of rows in a single view, I divided the unwrapping process into three separate views, each focusing on a specific attribute: genres, tags, or languages. This modular approach made the analysis more manageable and organized. Additionally, I included extra columns in each view to sort or categorize the data, providing greater flexibility for future analysis.
Your approach to breaking down the unwrapping into three separate views is an excellent decision for managing the dataset's complexity and avoiding an overwhelming number of rows in a single view. This also keeps your analysis more modular and easier to manage, as each view focuses on a specific attribute (genres, tags, and languages). Including additional columns in each view to sort or categorize the data is also a smart move for future flexibility.


### Why This Approach Makes Sense

1.  **Modularity:**
    
    -   By creating separate views, you avoid combining too much information into a single result set. This ensures that each view remains focused and manageable.
    -   If you need to join these views later, you can do so selectively based on your analysis requirements.
2.  **Scalability:**
    
    -   Splitting the data into smaller chunks (genres, tags, languages) prevents the creation of a view that could grow exponentially if multiple unwrapped columns were combined in a single view.
3.  **Predictive Categorization:**
    
    -   Including columns like `avg_playtime_in_hours`, `positive`, `negative`, `recommendations`, `Metacritic score`, and `Estimated sale` provides valuable metrics for sorting and categorizing the unwrapped values. This ensures the views are not only descriptive but also actionable for analysis.
    -   For example:
        -   **Genres**: Analyze the average playtime for each genre or its correlation with positive reviews.
        -   **Tags**: Identify which tags are most associated with high playtimes or recommendations.
        -   **Languages**: Understand language support trends over time and their impact on playtime or sales.
4.  **Efficient Filtering and Aggregation:**
    
    -   By unwrapping and associating relevant metrics upfront, you allow for easy filtering and aggregation within the views (e.g., summing sales by genre or averaging playtime by tag).
    -   You’ve effectively created pre-processed datasets that are easier to query for insights.

## An analysis of the visualization approach
The approach to creating a single-page Power BI dashboard with year and KPI slicers is a strong start for creating a valueable and concise dashboard.



-   **Year Slicer:**  
    Including a year slicer for filtering data over time. This allows users to explore trends and changes in metrics (like sales, playtime, etc.) across different time periods. Using a range slider or a dropdown will make the interaction smoother.
    
-   **KPI Switch:**  
    A KPI switch (using a button or slicer) is for maximizing space while providing flexibility. It lets users focus on a specific KPI in various visualizations without cluttering the dashboard. This approach avoids overloading the page with multiple KPI-specific graphs.
    
-   **Single-Page Design:**  
    Prioritizing a single page forces the design to focus on critical insights and interactions. However, crucial not to overcrowd the dashboard—too much information can overwhelm the user. Using techniques like collapsible panels or tooltips can present additional details.
    


### 2. **Additional KPIs for Added Value**

The following KPIs can be considered for maximizing the dashboard's value:

-   **Positive-to-Negative Ratio:**  
    A ratio of positive to negative reviews gives a quick understanding of how well-received a game is.
    
    ```sql
    Positive-to-Negative Ratio = positive / NULLIF(negative, 0)
    
    ```
    
-   **Sales per Hour of Playtime:**  
    A measure of how much revenue each hour of gameplay generates.
    
    ```sql
    Sales per Hour = Estimated Sale / NULLIF("Average playtime forever", 0)
    
    ```
    
-   **Recommendation Rate:**  
    The percentage of recommendations relative to total reviews.
    
    ```sql
    Recommendation Rate = recommendations / (positive + negative)
    
    ```
    
-   **Genre/Tag Popularity:**  
    The percentage of games in a genre or tag relative to the total.
    
    ```sql
    Popularity = COUNT(games in genre or tag) / COUNT(total games)
    
    ```

    

    

----------

### 3. **Using a Switch for KPI in Power BI**

The **Switch Function** in Power BI is ideal for letting users toggle between KPIs. Here’s how you can implement it:

#### **Step 1: Creating a KPI Selector Table**

1.  Creating a new table in Power BI with the KPIs:
    
    
  
|KPI Name| KPI Value |
|--|--|
| 1 | Estimated_Sale |
| 2 |avg_playtime_in_hours|
| 3 |metacritic_score|
| 4 | positive_to_negative |
| 5 | recommendation_rate |  
2.  Adding this table to the model and creating a slicer from it.
----------

#### **Step 2: Creating a Measure for the Selected KPI**

1.  Defining a measure that uses the selected KPI from the slicer:
    
    ```DAX
    Selected KPI Value = 
    SWITCH(
        SELECTEDVALUE('KPI Selector'[KPI ID]),
        1, SUM('steam_project'[Estimated Sale]),
        2, AVERAGE('steam_project'["Average playtime forever"]),
        3, AVERAGE('steam_project'["Metacritic score"]),
        4, SUM('steam_project'[positive]) / SUM('steam_project'[negative]),
        5, SUM('steam_project'[recommendations]) / (SUM('steam_project'[positive]) + SUM('steam_project'[negative])),
        BLANK()
    )
    
    ```
    

    

----------

#### **Step 3: Using the Measure in Visuals**

-   Replacing static values in the graphs and charts with the `Selected KPI Value` measure. This makes the visuals dynamic based on the KPI chosen in the slicer.




