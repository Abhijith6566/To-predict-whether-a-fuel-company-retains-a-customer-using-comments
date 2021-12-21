# To-predict-whether-a-fuel-company-retains-a-customer-using-comments

# Introduction

A fuel company has 250+ gas stations in the US. It captures customers’ comments via phone, which are merged with numeric variables by matching them with the company’s royalty card number. All data were provided in the Gas_text_numeric_data file. Some of the text comments, variable names, and descriptions were disguised to protect the identity of the client company.

# Data

- The target variable is identified by the column name. 
- Cust_ID, and Loyal_Status are nominal variables, and all other variables are binary.
- Comment column contains the text information.

![image](https://user-images.githubusercontent.com/86455496/146852162-d1e7eabf-db86-4703-b9b4-ffe6ec20880e.png)


# Model


Performed topic modeling with 4 topics

o Further removed some common words, such as “shower” & “point”
o The term/beat plots for four topics.
![image](https://user-images.githubusercontent.com/86455496/146852118-71c0e816-1ffd-43ba-ab8e-4cda3fb0d7bc.png)

ran two decision tree models :

o Model 1 only uses non-text information (i.e., all other columns except the Comment 
column)

![image](https://user-images.githubusercontent.com/86455496/146852203-6eac4c5b-c52f-4a79-ab3d-5cdd786ef853.png)

o Model 2 combines both non-text and text information
> Text mine the Comment column
> Applied SVD to extract text information from the Comment column
> Kept the number of SVD as 8
> Combine 8 SVD with all other columns except the Comment column

![image](https://user-images.githubusercontent.com/86455496/146852242-71f99362-4db2-4534-84a7-f5be442e90b8.png)

> model performance of two models compared based on the confusion matrix of the validation datase
The model with both non-text and text information gave a better metrics than model 1 with accuracy of 0.60 where model without text gave accuracy of 0.52
