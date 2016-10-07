port module Main exposing (..)

import Html exposing (..)
import Html.App as App

import Material.Layout as Layout
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)

import Material.Grid exposing(..)
import Material.Card as Card 
import Material.Button as Button 
import Material.Icon as Icon
import Material.Elevation as Elevation
import Material.Color as Color
import Material.Options as Options exposing (cs, css)
import Material
import Material.Typography as Typography
import Material.Tabs as Tabs
import Material.Helpers exposing (map1st, map2nd)
import Material.List as Lists
import Material.Icon as Icon
import Material.Tabs as Tabs

main : Program Never
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- model

type alias Model =
  { dwarves : List Dwarf
  , selectedDwarf: Dwarf
  , selectedDwarfTab: Int
  , mdl : Material.Model
  }

init : (Model, Cmd Msg)
init =
  (Model [] initDwarf 1 Material.model, Cmd.none)


type alias Dwarf =
  { name: String
  , profession: String
  , stressLevel: String
  , currentJob: String 
  , inventory: List Item
  , buildings: List Building
  , skills: List Skill
  }

initDwarf : Dwarf
initDwarf =
  Dwarf "" "" "" "" [] [] []

type alias Item = 
  { name: String
  , stackSize: Int
  , subtype: String
  }

type alias Building =
  { name: String
  }

type alias Skill =
  { name: String
  , ratingCaption: String 
  , ratingValue: Int
  , xp: Int
  , maxXp: Int
  }


-- update

type Msg 
  = RenderDwarves (List Dwarf)
  | ClickDwarf Dwarf
  | SelectDwarfTab Int
  | Mdl (Material.Msg Msg)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    RenderDwarves dwarves ->
      ( { model | dwarves = dwarves }, Cmd.none)
    ClickDwarf dwarf ->
      ( { model | selectedDwarf = dwarf }, Cmd.none)
    SelectDwarfTab index ->
      ( { model | selectedDwarfTab = index }, Cmd.none)
    Mdl msg' ->
            Material.update msg' model



-- view

type alias Mdl =
    Material.Model

view : Model -> Html.Html Msg
view model =
    Layout.render Mdl
        model.mdl
        [ Layout.fixedHeader
        ]
        { header = [ h1 [ style [ ( "font-size", "20px" ), ("margin", "20px") ] ] [ text "Dwarf Explorer" ] ]
        , drawer = []
        , tabs = ( [], [] )
        , main = [ viewBody model ]
        }

viewBody : Model -> Html.Html Msg
viewBody model =
  div []
    [ grid []
        [ cell [ size All 2 ]
            [ renderList model.dwarves model.selectedDwarf
            ]
        , cell [ size All 8 ]
            [ renderDwarfDetails model
            ]
        ]
    ]

renderList : List Dwarf -> Dwarf -> Html.Html Msg
renderList list selectedDwarf =
  list
      |> List.map (\l -> 
        let
          fontWeight = 
            if l.name == selectedDwarf.name then
              "bold"
            else
              "normal"

          width =
            if l.name == selectedDwarf.name then
              "150px"
            else
              "128px" 
        in
          Card.view  
            [ css "width" width
            , css "margin" "5px"  
            , Color.background (Color.color Color.Indigo Color.S100)
            -- Click
            , Options.attribute <| Html.Events.onClick (ClickDwarf l)
            ]
            [ Card.title [] [ Card.head [ Color.text Color.black, css "font-weight" fontWeight ] [ text l.name ] ]
            ]
          ) 
      |> div []

renderDwarfDetails : Model -> Html.Html Msg
renderDwarfDetails model =
  if model.selectedDwarf.name == "" then
    text "No dwarf selected"
  else
    Tabs.render Mdl [0] model.mdl
      [ Tabs.ripple
      , Tabs.onSelectTab SelectDwarfTab
      , Tabs.activeTab model.selectedDwarfTab
      ]
      [ Tabs.label 
          [ Options.center ] 
          [ Icon.i "info_outline"
          , Options.span [ css "width" "4px" ] []
          , text model.selectedDwarf.name 
          ]
      , Tabs.label 
          [ Options.center ] 
          [ Icon.i "build"
          , Options.span [ css "width" "4px" ] []  
          , text "Skills" 
          ]
      ]
      [ case model.selectedDwarfTab of
          0 -> text "about"
          _ -> renderSkillsList model.selectedDwarf.skills
      ]
    
    -- Lists.ul []
    --   [ Lists.li [] [ Lists.content [] [ text ("Name: " ++ dwarf.name) ] ]
    --   , Lists.li [] [ Lists.content [] [ text ("Profession: " ++ dwarf.profession) ] ]
    --   , Lists.li [ css "margin-left" "25px" ] [ renderSkillsList dwarf.skills ]
    --   ] 

renderSkillsList: List Skill -> Html.Html Msg
renderSkillsList skills =
  Lists.ul []
      ( List.map (\s -> (Lists.li [] [ Lists.content [] [ text ( s.name ++ " " ++ ( toString s.ratingValue ) ++ " " ++ s.ratingCaption ) ] ]) ) skills )



-- subscriptions
port dwarfList : (List Dwarf -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  --Sub.batch
  --[ 
  dwarfList RenderDwarves
  --]
  
