import cdsapi
c = cdsapi.Client()

c.retrieve("dataset-short-name", 
           {... sub-selection request ...},
           "target-file")
