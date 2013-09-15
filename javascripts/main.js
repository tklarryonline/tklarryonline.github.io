function bindLogo() {
	$("#tk-logo.flat-icon").flatshadow({
		// Shadows direction. 
		// Available options: N, NE, E, SE, S, SW, W and NW.
		// (Angle will be random if left unassigned)
		// Gradient shadow effect
		fade: false 
	});
}

$(function() {
	bindLogo();
});

