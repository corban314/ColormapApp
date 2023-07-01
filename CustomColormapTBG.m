function [f,ax1] = makeCustomDisplacementColorPlot()
            if nargin < 2
                SP_hsv = [0.8,0.8,1];
                AB_hsv = [0.5,0.3,1];
            end
            if nargin < 4
                continuity_threshold = [];
            end
            if nargin < 5
                filter_range = 3;
            end
            if nargin < 6
                SP_unique_flag = 0;
            end
            if nargin < 7
                usePrefactorFit = 0;
            end
            if nargin < 8
                useHotspotSuppression = false;
            end
            if nargin < 9
                savePlot = false;
            end
            if nargin < 10
                useAnnealedDfield = false;
            end
            if isempty(SP_hsv) || isempty(AB_hsv)
                if ~SP_unique_flag
                    SP_hsv = [0.8,0.8,1];
                    AB_hsv = [0.5,0.3,1];
                else  % no coordination with the color triangle needed; let the function figure out its own colors.
                    SP_hsv = [];
                    AB_hsv = [];
                end
            end
            grid_density = 0.01;
            % [ raster_points ] = getDSCHexagonRaster(grid_density,2.461);
            xbase = -1.5:grid_density:1.5;
            ybase = 0:grid_density:1.5;
            [xspace,yspace] = meshgrid(xbase,ybase);
            catmat = cat(3,xspace,yspace);
            
            [ RGB_color_stack ] = getCustomDisplacementColor( catmat, SP_hsv, AB_hsv, SP_unique_flag );
            figure;
            imagesc(xbase,ybase,RGB_color_stack);   
            set(gca,'ydir','normal');
            axis equal
            title('2D Colormap');
            xlabel('x displacement');
            ylabel('y displacement');
            
            if isa(continuity_threshold,'struct')  % the new filter protocol
                if useAnnealedDfield
                    xdisp = obj.annealed_dfield(:,:,1);
                    ydisp = obj.annealed_dfield(:,:,2);
                else
                    xdisp = obj.DSC_fit_storage(:,:,1);
                    ydisp = obj.DSC_fit_storage(:,:,2);
                end
                filterstruct = continuity_threshold;
                plotflag = 0;
                [ xdisp_filt,ydisp_filt ] = filterDisplacement( xdisp,ydisp,filterstruct,plotflag,obj );
                displacement_to_use = cat(3,xdisp_filt,ydisp_filt);
            else
                if usePrefactorFit
                    displacement_to_use = obj.prefactor_fit_DSC_storage;
                else
                    if ~isempty(continuity_threshold)
                        if isempty(obj.hotspot_suppression_mask) || ~useHotspotSuppression
                            displacement_to_use = obj.displacementContinuityFilter(continuity_threshold,filter_range);
                        else
                            hard_flag = 1;  % by default here.
                            displacement_to_use = obj.displacementContinuityFilter(continuity_threshold,filter_range,hard_flag,[],[],useHotspotSuppression);
                        end
                    else
                        displacement_to_use = obj.DSC_fit_storage;
                    end
                    if useHotspotSuppression && isempty(obj.hotspot_suppression_mask)
                        displacement_to_use = obj.suppressHotspots(displacement_to_use);
                    end
                end
            end
            
            if useAnnealedDfield  % Need to convert back to reduced zone
                xdisp = displacement_to_use(:,:,1);
                ydisp = displacement_to_use(:,:,2);
                [ reduced_zone_disps ] = extendedZoneDisp2ReducedZoneDisp( [xdisp(:),ydisp(:)] );
                xdisp_rz = reshape(reduced_zone_disps(:,1),size(xdisp));
                ydisp_rz = reshape(reduced_zone_disps(:,2),size(ydisp));
                displacement_to_use = cat(3,xdisp_rz,ydisp_rz);
            end
            
            [ RGB_color_stack ] = getCustomDisplacementColor( displacement_to_use, SP_hsv, AB_hsv, SP_unique_flag );
            f = figure;
            set(f,'Position',[200,200,800,700]);
            if ~SP_unique_flag
                ax1 = subplot(1,2,1);
                ax2 = subplot(1,2,2);
                axes(ax1);
            else
                ax1 = gca;
            end
            % NPK changed on 05/24/2020 from the following to make dataset 10 work:
%             if numel(obj.xaxis) == size(displacement_to_use,1) && numel(obj.yaxis) == size(displacement_to_use,2)
            if numel(obj.xaxis) == size(displacement_to_use,2) && numel(obj.yaxis) == size(displacement_to_use,1)
                imagesc(obj.xaxis,obj.yaxis,RGB_color_stack);
                xlabel('Real space x (nm)','FontSize',12);
                ylabel('Real space y (nm)','FontSize',12);
            else
                imagesc(RGB_color_stack);
                xlabel('Pixels x','FontSize',12);
                ylabel('Pixels y','FontSize',12);
                warning('Data dimensions do not seem to match axis dimensions. This may be due to fitting a cropped portion of the full datacube.');
            end
            set(ax1,'ydir','normal');
            axis square
            
            title('Colorized AB, SP, and AA regions','FontSize',14);
            hold on
            if ~SP_unique_flag
                set(ax1,'Position',[0.05 0.1 0.7 0.75]);
            end
            set(ax1,'FontSize',12);
            
            if ~SP_unique_flag
                [ RGB_color_stack_legend ] = getTriangleColorLegend(grid_density,AB_hsv,SP_hsv);
                legaxpos = [0.8,0.1,0.15,0.15];
                set(ax2,'Position',legaxpos);
                axes(ax2);
                imagesc(RGB_color_stack_legend);
                set(ax2,'ydir','normal');
                set(ax2,'Box','off');
                set(ax2,'XMinorTick','off');
                set(ax2,'YMinorTick','off');
                set(ax2,'XTick',[]);
                set(ax2,'YTick',[]);
                set(ax2,'visible','off');
                
                vertical_increment = 0.06;
                horizontal_increment = 0;% 0.0125;
                axsize = [0.05,0.05];
                th1 = axes('Position',[legaxpos(1)-horizontal_increment, legaxpos(2)-vertical_increment/1.4,axsize]);
                text(.025,.6,'AA','FontSize',12,'HorizontalAlignment','Center')
                set(th1,'visible','off');
                th1.XTick = [];
                th1.YTick = [];
                th2 = axes('Position',[legaxpos(1)+legaxpos(3)-horizontal_increment, legaxpos(2)-vertical_increment/1.4,axsize]);
                text(.025,.6,'SP','FontSize',12,'HorizontalAlignment','Center')
                set(th2,'visible','off');
                th2.XTick = [];
                th2.YTick = [];
                th3 = axes('Position',[legaxpos(1)+legaxpos(3)/2-horizontal_increment,legaxpos(2)+legaxpos(4)-vertical_increment/2,axsize]);
                text(.025,.6,'AB','FontSize',12,'HorizontalAlignment','Center')
                set(th3,'visible','off');
                th3.XTick = [];
                th3.YTick = [];
                th4 = axes('Position',[legaxpos(1)+legaxpos(3)/2-horizontal_increment,legaxpos(2)+legaxpos(4)+vertical_increment/4,axsize]);
                set(th4,'visible','off');
                th4.XTick = [];
                th4.YTick = [];
                text(.025,.6,'Stacking Order:','FontSize',14,'HorizontalAlignment','Center')
            end
            
            axes(ax1);
            f = f;
            
            if savePlot
                currentd = pwd;
                cd(obj.saved_plots_folderpath);
                if ~exist(obj.saved_plots_foldername,'dir')
                    mkdir(obj.saved_plots_foldername);
                end
                cd(obj.saved_plots_foldername);
                savefig(f,'2DColormapDisplacementField');
                saveas(f,'2DColormapDisplacementField.png');
                cd(currentd);
            end
        end