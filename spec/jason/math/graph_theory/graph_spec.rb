RSpec.describe Jason::Math::GraphTheory::Graph do
  context "#shortest_path" do
    subject { graph.shortest_path(origin, destination) }

    context "stackoverflow example" do
      # example taken from https://stackoverflow.com/questions/30409493/using-bfs-for-weighted-graphs
      let(:origin) { 1 }
      let(:destination) { 5 }
      let(:graph) { described_class.new(vertices) }
      let(:vertices) { [1, 2, 3, 4, 5, 6] }

      before do
        graph.add_edge(1, 2, 7)
        graph.add_edge(1, 3, 9)
        graph.add_edge(1, 6, 14)
        graph.add_edge(2, 3, 10)
        graph.add_edge(2, 4, 15)
        graph.add_edge(3, 4, 11)
        graph.add_edge(3, 6, 2)
        graph.add_edge(4, 5, 6)
        graph.add_edge(6, 5, 9)
      end

      it { is_expected.to eq(20) }
    end
  end

  context "#longest_path" do
    subject { graph.longest_path(origin, destination) }

    context "for some graph" do
      # unverified
      let(:origin) { 1 }
      let(:destination) { 5 }
      let(:graph) { described_class.new(vertices) }
      let(:vertices) { [1, 2, 3, 4, 5, 6] }

      before do
        graph.add_edge(1, 2, 7)
        graph.add_edge(1, 3, 9)
        graph.add_edge(1, 6, 14)
        graph.add_edge(2, 3, 10)
        graph.add_edge(2, 4, 15)
        graph.add_edge(3, 4, 11)
        graph.add_edge(3, 6, 2)
        graph.add_edge(4, 5, 6)
        graph.add_edge(6, 5, 9)
      end

      it { is_expected.to eq(34) }
    end
  end
end