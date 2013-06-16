---
layout: post
title: Infield form labels
date: 2013-06-17 1:19:51
---

I have been searching for decades on how to increase the usability of form-field's label. Thus, reading this post about [**Making Infield Form Labels Suck Less**](http://viget.com/inspire/making-infield-form-labels-suck-less) inspired me.

I myself would prefer a form with field's label positioned above the field, left-indented. And the placeholder text inside the field would tell briefly what should be filled. Those together would probably bring the feeling of step-by-step, what-to-do towards the form.

However, using just the placeholder text are not really usable. There will be some use-cases that the user clicks on the field, placeholder text disappear and... our fellow user has to rely on their short-term memory to figure out what to do.

From the post I learned some great ways to attack the problem in term of UX. And finally felt interested in the solution idea:

> We ended up using the tooltip approach, placing labels above their input once the input has focus. We liked this approach because the active input labels are clearly distinct from other form elements, and the same approach can be used when the design scales down to smaller screens.

The [*actual implementation*](http://viget.com/inspire/making-infield-form-labels-suck-less-2) of this solution, surprisingly, was not as good as I expected. The label (as a tooltip) displayed and obscured the field above, which to me is not a good appeal. One thing that may help to overcome this problem, is to decrease the opacity a little bit to show the field above. Not right-into-the-eyes, but yet visually okay.
