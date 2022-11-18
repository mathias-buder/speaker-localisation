package mvc.main;


import mvc.controller.AppController;

public class Main {

	public static AppController controller;
	
	public static void main(String[] args) {
		// Create new controller and run it
		controller = new AppController();
		controller.setInstance(controller);
		controller.start();
	}


}
