# Optimistic Saving

This database presents a method for saving entities in 4D. It handles all the cases of a save function. 

A test method illustrates and discusses most of the common issues involved in optimistic saving. This also illustrates the nature of references and how you can have different references to the same record in different states at the same time. 

The EntitySave method includes an option for force-saving changes. This is a fairly brutal approach used here to illustrate options available to you for resolving locked record conflicts during a save. 
