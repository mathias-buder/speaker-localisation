function PlotDate2(Room, Array, Source, Point, AudioField, View, Param)

    for ViewCount = 1:length(View)
        subplot(length(View),1,ViewCount);
        PlotData( Room, Array, Source, Point, Param, AudioField, View(ViewCount,:));
    end

end