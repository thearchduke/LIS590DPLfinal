Hi there! Here you'll find the presentation version of the Cocoon project that I'll be submitting for this lovely Document Processing course.

The sitemap can provide a self-describing walkthrough, I suppose, but let's be a bit more specific here.

In the 'complex' folder, the two most important files to look at are the two 'canonical' files. That's the bulk of the transformation work.

The SVG is the colorless file I use to create the district vote maps. (Thanks, wikimedia!)

The /index URL converts links.xml into the index view through wanton abuse of the document() function, using the index_titletest.xsl transformation.
This URL will ultimately be an identity transformation on a saved version of what you see right now when you go to /index.

votes.xml and congBios.xml are files I made by hand that are instrumental in connecting districts, their representatives, and their representatives' votes, and are used in the production of the map.

The actual implementation can be found at http://cocoon.lis.illinois.edu:8080/lis590dpl/jtburke4/congress/index
