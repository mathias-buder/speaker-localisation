function SetWindowPos( Width )


    Screen.Size = get(0,'ScreenSize');
    Screen.Hight = Screen.Size(4);
    Screen.Width = Screen.Size(3);
    Window.Width = Width;
    Window.Hight = Screen.Hight-50;
    
    set(gcf, 'Position', [(Screen.Width-Window.Width) 0 Window.Width  Window.Hight]);
    

end